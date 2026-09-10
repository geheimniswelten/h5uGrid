[CmdletBinding()]
param(
    [ValidateSet(5, 10)]
    [int]$Seconds = 10,
    [string]$TestName = 'h5u.Grid'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Add-Type -ReferencedAssemblies System.Windows.Forms, System.Drawing -TypeDefinition @'
using System;
using System.Diagnostics;
using System.Drawing;
using System.Runtime.InteropServices;
using System.Windows.Forms;

public sealed class H5uVisualTestNotice : Form
{
    [DllImport("user32.dll")]
    private static extern bool SetProcessDpiAwarenessContext(IntPtr context);
    [DllImport("user32.dll")]
    private static extern IntPtr MonitorFromPoint(Point point, uint flags);
    [DllImport("shcore.dll")]
    private static extern int GetDpiForMonitor(IntPtr monitor, int kind, out uint x, out uint y);

    protected override bool ShowWithoutActivation { get { return true; } }
    protected override CreateParams CreateParams
    {
        get
        {
            CreateParams result = base.CreateParams;
            result.ExStyle |= 0x08000000; // WS_EX_NOACTIVATE
            return result;
        }
    }

    private static Label AddLabel(Form form, string text, float size, FontStyle style,
        Color color, int top, int height, float scale)
    {
        Label label = new Label();
        label.Text = text;
        label.Font = new Font("Segoe UI", size * scale, style, GraphicsUnit.Pixel);
        label.ForeColor = color;
        label.TextAlign = ContentAlignment.MiddleCenter;
        label.AutoEllipsis = true;
        label.SetBounds(20, (int)(top * scale), form.ClientSize.Width - 40, (int)(height * scale));
        form.Controls.Add(label);
        return label;
    }

    public static bool RunNotice(int seconds, string testName)
    {
        if (!Environment.UserInteractive)
            throw new InvalidOperationException("Ein interaktiver Desktop ist erforderlich.");
        SetProcessDpiAwarenessContext(new IntPtr(-4)); // Per-monitor DPI awareness v2.
        Application.EnableVisualStyles();
        Point cursor = Cursor.Position;
        Screen screen = Screen.FromPoint(cursor);
        Rectangle area = screen.WorkingArea;
        uint dpiX, dpiY;
        float scale = GetDpiForMonitor(MonitorFromPoint(cursor, 2), 0, out dpiX, out dpiY) == 0
            ? Math.Max(1f, dpiX / 96f) : 1f;
        bool completed = false;

        using (H5uVisualTestNotice form = new H5uVisualTestNotice())
        using (Timer timer = new Timer())
        {
            form.Text = "h5u.Grid – Visuelle Tests";
            form.AutoScaleMode = AutoScaleMode.None;
            form.FormBorderStyle = FormBorderStyle.None;
            form.StartPosition = FormStartPosition.Manual;
            form.ClientSize = new Size(Math.Min((int)(640 * scale), area.Width - 40), (int)(230 * scale));
            form.Location = new Point(area.Left + (area.Width - form.Width) / 2,
                area.Top + (area.Height - form.Height) / 2);
            form.BackColor = Color.FromArgb(30, 35, 44);
            form.TopMost = true;
            form.ShowInTaskbar = false;
            AddLabel(form, "Visuelle Tests", 24, FontStyle.Bold, Color.White, 18, 36, scale);
            AddLabel(form, testName, 16, FontStyle.Regular, Color.LightGray, 57, 26, scale);
            Label countdown = AddLabel(form, "", 32, FontStyle.Bold, Color.FromArgb(104, 186, 255), 88, 48, scale);
            AddLabel(form, "Bitte Maus und Tastatur gleich kurz freigeben.", 17,
                FontStyle.Regular, Color.White, 145, 40, scale);
            ProgressBar progress = new ProgressBar();
            progress.Maximum = seconds * 10;
            progress.Value = progress.Maximum;
            progress.SetBounds(24, (int)(204 * scale), form.ClientSize.Width - 48, (int)(6 * scale));
            form.Controls.Add(progress);
            Stopwatch elapsed = new Stopwatch();
            countdown.Text = "Start in " + seconds + " Sekunden";
            timer.Interval = 100;
            form.Shown += delegate
            {
                Console.WriteLine("NOTICE monitor={0} area={1} bounds={2}", screen.DeviceName, area, form.Bounds);
                elapsed.Start(); // The full lead time starts only once the notice is visible.
                timer.Start();
            };
            timer.Tick += delegate
            {
                double remaining = seconds - elapsed.Elapsed.TotalSeconds;
                if (remaining <= 0)
                {
                    completed = true;
                    timer.Stop();
                    form.Close();
                    return;
                }
                int displayed = (int)Math.Ceiling(remaining);
                countdown.Text = "Start in " + displayed + (displayed == 1 ? " Sekunde" : " Sekunden");
                progress.Value = Math.Min(progress.Maximum, Math.Max(0, (int)(remaining * 10)));
            };
            Application.Run(form);
            Console.WriteLine("NOTICE elapsed={0:F3}s completed={1}", elapsed.Elapsed.TotalSeconds, completed);
        }
        return completed;
    }
}
'@

if (-not [H5uVisualTestNotice]::RunNotice($Seconds, $TestName)) {
    exit 2
}
