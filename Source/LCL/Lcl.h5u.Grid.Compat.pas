unit Lcl.h5u.Grid.Compat;

{$MODE OBJFPC}{$H+}
{$MODESWITCH ADVANCEDRECORDS}

interface

uses
  Types;

type
  Th5uLclRectFHelper = record helper for TRectF
    class function Create(ALeft, ATop, ARight, ABottom: Single): TRectF; overload; static;
    class function Create(const ARect: TRect): TRectF; overload; static;
    function Round: TRect;
    function Contains(const APoint: TPointF): Boolean;
  end;

function PointF(AX, AY: Single): TPointF;
function RectF(ALeft, ATop, ARight, ABottom: Single): TRectF;

implementation

function PointF(AX, AY: Single): TPointF;
begin
  Result := TPointF.Create(AX, AY);
end;

function RectF(ALeft, ATop, ARight, ABottom: Single): TRectF;
begin
  Result := TRectF.Create(ALeft, ATop, ARight, ABottom);
end;

class function Th5uLclRectFHelper.Create(ALeft, ATop, ARight, ABottom: Single): TRectF;
begin
  Result.Left := ALeft;
  Result.Top := ATop;
  Result.Right := ARight;
  Result.Bottom := ABottom;
end;

class function Th5uLclRectFHelper.Create(const ARect: TRect): TRectF;
begin
  Result := Create(ARect.Left, ARect.Top, ARect.Right, ARect.Bottom);
end;

function Th5uLclRectFHelper.Round: TRect;
begin
  Result := Rect(System.Round(Left), System.Round(Top), System.Round(Right), System.Round(Bottom));
end;

function Th5uLclRectFHelper.Contains(const APoint: TPointF): Boolean;
begin
  Result := (APoint.X >= Left) and (APoint.X < Right) and (APoint.Y >= Top) and (APoint.Y < Bottom);
end;

end.
