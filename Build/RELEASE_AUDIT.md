# Reproduzierbarer Release-Audit

**Stand:** 1. September 2026

- Source-Units: **20**
- Demo-Projekte: **6**
- Harte Befunde: **91**
- Warnungen: **0**

## Prüfungen

- `required-layout`: 0 Fehler, 0 Warnungen
- `unit-namespaces`: 0 Fehler, 0 Warnungen
- `identifier-casing`: 0 Fehler, 0 Warnungen
- `project-paths`: 0 Fehler, 0 Warnungen
- `form-resources`: 0 Fehler, 0 Warnungen
- `feature-signatures`: 8 Fehler, 0 Warnungen
- `source-policy`: 18 Fehler, 0 Warnungen
- `method-coverage`: 65 Fehler, 0 Warnungen
- `tree-sitter-pascal`: 0 Fehler, 1 Warnungen – optional dependency unavailable

## Befunde

- **ERROR** `Source/Common/h5u.Grid.Factory.pas` – Erwartete Prototyp-Signatur fehlt: \bGrid\s*:
- **ERROR** `Source/Common/h5u.Grid.Factory.pas` – Erwartete Prototyp-Signatur fehlt: \bView\s*:
- **ERROR** `Source/Common/h5u.Grid.Factory.pas` – Erwartete Prototyp-Signatur fehlt: \bDataController\s*:
- **ERROR** `Source/Common/h5u.Grid.Factory.pas` – Erwartete Prototyp-Signatur fehlt: \bColumn\s*:
- **ERROR** `Source/Common/h5u.Grid.Factory.pas` – Erwartete Prototyp-Signatur fehlt: \bRowKey\s*:
- **ERROR** `Source/Common/h5u.Grid.Options.pas` – Erwartete Prototyp-Signatur fehlt: WholeRows
- **ERROR** `Source/Common/h5u.Grid.Options.pas` – Erwartete Prototyp-Signatur fehlt: PixelSnap
- **ERROR** `Source/Common/h5u.Grid.Options.pas` – Erwartete Prototyp-Signatur fehlt: ThumbHint
- **ERROR** `Source/Vcl/Vcl.h5u.Grid.pas:1307` – Kandidat für direkte Factory-Umgehung: Th5uGridColumns.Create
- **ERROR** `Source/Vcl/Vcl.h5u.Grid.pas:1309` – Kandidat für direkte Factory-Umgehung: Th5uHeaderLayout.Create
- **ERROR** `Source/Vcl/Vcl.h5u.Grid.pas:2417` – Kandidat für direkte Factory-Umgehung: Th5uCellRange.Create
- **ERROR** `Source/Vcl/Vcl.h5u.Grid.pas:2424` – Kandidat für direkte Factory-Umgehung: Th5uCellRange.Create
- **ERROR** `Source/Vcl/Vcl.h5u.Grid.pas:2458` – Kandidat für direkte Factory-Umgehung: Th5uCellRange.Create
- **ERROR** `Source/Common/h5u.Grid.Data.Core.pas:308` – Kandidat für direkte Factory-Umgehung: Th5uDataViewSession.Create
- **ERROR** `Source/Common/h5u.Grid.Types.pas:402` – Kandidat für direkte Factory-Umgehung: Th5uCellRange.Create
- **ERROR** `Source/Common/h5u.Grid.Columns.pas:300` – Kandidat für direkte Factory-Umgehung: Th5uGridColumn.Create
- **ERROR** `Source/Common/h5u.Grid.Columns.pas:411` – Kandidat für direkte Factory-Umgehung: Th5uGridColumns.Create
- **ERROR** `Source/Common/h5u.Grid.Columns.pas:520` – Kandidat für direkte Factory-Umgehung: Th5uHeaderLayoutCell.Create
- **ERROR** `Source/Common/h5u.Grid.Columns.pas:545` – Kandidat für direkte Factory-Umgehung: Th5uHeaderLayoutCells.Create
- **ERROR** `Source/Common/h5u.Grid.Columns.pas:570` – Kandidat für direkte Factory-Umgehung: Th5uHeaderLayout.Create
- **ERROR** `Source/Common/h5u.Grid.Columns.pas:576` – Kandidat für direkte Factory-Umgehung: Th5uHeaderLayoutCells.Create
- **ERROR** `Source/FMX/FMX.h5u.Grid.pas:1034` – Kandidat für direkte Factory-Umgehung: Th5uGridColumns.Create
- **ERROR** `Source/FMX/FMX.h5u.Grid.pas:1036` – Kandidat für direkte Factory-Umgehung: Th5uHeaderLayout.Create
- **ERROR** `Source/FMX/FMX.h5u.Grid.pas:1747` – Kandidat für direkte Factory-Umgehung: Th5uCellRange.Create
- **ERROR** `Source/FMX/FMX.h5u.Grid.pas:2220` – Kandidat für direkte Factory-Umgehung: Th5uFmxImageEditor.Create
- **ERROR** `Source/FMX/FMX.h5u.Grid.Editors.pas:56` – Kandidat für direkte Factory-Umgehung: Th5uFmxImageEditor.Create
- **ERROR** `Source/Vcl/Vcl.h5u.Grid.pas` – Th5uVclGrid.empty: 1 Deklaration(en), 0 Implementierung(en)
- **ERROR** `Source/Vcl/Vcl.h5u.Grid.pas` – Th5uVclGrid.paintdefault: 3 Deklaration(en), 0 Implementierung(en)
- **ERROR** `Source/Vcl/Vcl.h5u.Grid.pas` – Th5uVclGrid.effectivebackground: 1 Deklaration(en), 0 Implementierung(en)
- **ERROR** `Source/Vcl/Vcl.h5u.Grid.pas` – Th5uVclGrid.effectiveforeground: 1 Deklaration(en), 0 Implementierung(en)
- **ERROR** `Source/Vcl/Vcl.h5u.Grid.pas` – Th5uVclGrid.bindcell: 1 Deklaration(en), 0 Implementierung(en)
- **ERROR** `Source/Vcl/Vcl.h5u.Grid.pas` – Th5uVclGrid.paint: 2 Deklaration(en), 1 Implementierung(en)
- **ERROR** `Source/Vcl/Vcl.h5u.Grid.pas` – Th5uVclGrid.ensurepicture: 1 Deklaration(en), 0 Implementierung(en)
- **ERROR** `Source/Vcl/Vcl.h5u.Grid.pas` – Th5uVclGrid.destroy: 2 Deklaration(en), 1 Implementierung(en)
- **ERROR** `Source/Common/h5u.Grid.Data.Core.pas` – Th5uCustomDataController.setcontroller: 1 Deklaration(en), 0 Implementierung(en)
- **ERROR** `Source/Common/h5u.Grid.Data.Core.pas` – Th5uCustomDataController.destroy: 2 Deklaration(en), 1 Implementierung(en)
- **ERROR** `Source/Common/h5u.Grid.Data.Core.pas` – Th5uCustomDataController.datachanged: 1 Deklaration(en), 0 Implementierung(en)
- **ERROR** `Source/Common/h5u.Grid.Data.Core.pas` – Th5uCustomDataController.create: 2 Deklaration(en), 1 Implementierung(en)
- **ERROR** `Source/Common/h5u.Grid.Data.Core.pas` – Th5uCustomDataController.nextquerygeneration: 1 Deklaration(en), 0 Implementierung(en)
- **ERROR** `Source/Common/h5u.Grid.Data.Core.pas` – Th5uCustomDataController.getsourcevalue: 1 Deklaration(en), 0 Implementierung(en)
- **ERROR** `Source/Common/h5u.Grid.Data.Core.pas` – Th5uCustomDataController.h5uvaluetodisplaytext: 1 Deklaration(en), 0 Implementierung(en)
- **ERROR** `Source/Common/h5u.Grid.Data.Core.pas` – Th5uCustomDataController.h5utryvalueasinteger: 1 Deklaration(en), 0 Implementierung(en)
- **ERROR** `Source/Common/h5u.Grid.Data.DataSet.pas` – Th5uDataSetController.activechanged: 1 Deklaration(en), 0 Implementierung(en)
- **ERROR** `Source/Common/h5u.Grid.Data.DataSet.pas` – Th5uDataSetController.datasetchanged: 2 Deklaration(en), 1 Implementierung(en)
- **ERROR** `Source/Common/h5u.Grid.Data.DataSet.pas` – Th5uDataSetController.datasetscrolled: 1 Deklaration(en), 0 Implementierung(en)
- **ERROR** `Source/Common/h5u.Grid.Data.DataSet.pas` – Th5uDataSetController.layoutchanged: 1 Deklaration(en), 0 Implementierung(en)
- **ERROR** `Source/Common/h5u.Grid.Data.DataSet.pas` – Th5uDataSetController.recordchanged: 1 Deklaration(en), 0 Implementierung(en)
- **ERROR** `Source/Common/h5u.Grid.Data.DataSet.pas` – Th5uDataSetController.create: 3 Deklaration(en), 1 Implementierung(en)
- **ERROR** `Source/Common/h5u.Grid.Data.DataSet.pas` – Th5uDataSetController.destroy: 2 Deklaration(en), 1 Implementierung(en)
- **ERROR** `Source/Common/h5u.Grid.Factory.pas` – Th5uFactoryObject.create: 3 Deklaration(en), 1 Implementierung(en)
- **ERROR** `Source/Common/h5u.Grid.Factory.pas` – Th5uFactoryObject.findlocalclass: 1 Deklaration(en), 0 Implementierung(en)
- **ERROR** `Source/Common/h5u.Grid.Factory.pas` – Th5uFactoryObject.validateclass: 1 Deklaration(en), 0 Implementierung(en)
- **ERROR** `Source/Common/h5u.Grid.Factory.pas` – Th5uFactoryObject.setparent: 1 Deklaration(en), 0 Implementierung(en)
- **ERROR** `Source/Common/h5u.Grid.Factory.pas` – Th5uFactoryObject.destroy: 2 Deklaration(en), 0 Implementierung(en)
- **ERROR** `Source/Common/h5u.Grid.Factory.pas` – Th5uFactoryObject.registerclass: 1 Deklaration(en), 0 Implementierung(en)
- **ERROR** `Source/Common/h5u.Grid.Factory.pas` – Th5uFactoryObject.unregister: 1 Deklaration(en), 0 Implementierung(en)
- **ERROR** `Source/Common/h5u.Grid.Factory.pas` – Th5uFactoryObject.clear: 1 Deklaration(en), 0 Implementierung(en)
- **ERROR** `Source/Common/h5u.Grid.Factory.pas` – Th5uFactoryObject.resolveclass: 1 Deklaration(en), 0 Implementierung(en)
- **ERROR** `Source/Common/h5u.Grid.Factory.pas` – Th5uFactoryObject.createinstance: 1 Deklaration(en), 0 Implementierung(en)
- **ERROR** `Source/Common/h5u.Grid.Factory.pas` – Th5uFactoryObject.configureinstance: 1 Deklaration(en), 0 Implementierung(en)
- **ERROR** `Source/Common/h5u.Grid.Factory.pas` – Th5uFactoryObject.bindinstance: 1 Deklaration(en), 0 Implementierung(en)
- **ERROR** `Source/Common/h5u.Grid.Factory.pas` – Th5uFactoryObject.unbindinstance: 1 Deklaration(en), 0 Implementierung(en)
- **ERROR** `Source/Common/h5u.Grid.Factory.pas` – Th5uFactoryObject.getongetclass: 1 Deklaration(en), 0 Implementierung(en)
- **ERROR** `Source/Common/h5u.Grid.Factory.pas` – Th5uFactoryObject.setongetclass: 1 Deklaration(en), 0 Implementierung(en)
- **ERROR** `Source/Common/h5u.Grid.Factory.pas` – Th5uFactoryObject.getoncreateinstance: 1 Deklaration(en), 0 Implementierung(en)
- **ERROR** `Source/Common/h5u.Grid.Factory.pas` – Th5uFactoryObject.setoncreateinstance: 1 Deklaration(en), 0 Implementierung(en)
- **ERROR** `Source/Common/h5u.Grid.Factory.pas` – Th5uFactoryObject.getonconfigureinstance: 1 Deklaration(en), 0 Implementierung(en)
- **ERROR** `Source/Common/h5u.Grid.Factory.pas` – Th5uFactoryObject.setonconfigureinstance: 1 Deklaration(en), 0 Implementierung(en)
- **ERROR** `Source/Common/h5u.Grid.Factory.pas` – Th5uFactoryObject.h5uglobalfactoryscope: 1 Deklaration(en), 0 Implementierung(en)
- **ERROR** `Source/Common/h5u.Grid.Columns.pas` – Th5uGridColumn.getdisplayname: 3 Deklaration(en), 1 Implementierung(en)
- **ERROR** `Source/Common/h5u.Grid.Columns.pas` – Th5uGridColumn.create: 6 Deklaration(en), 1 Implementierung(en)
- **ERROR** `Source/Common/h5u.Grid.Columns.pas` – Th5uGridColumn.assign: 2 Deklaration(en), 1 Implementierung(en)
- **ERROR** `Source/Common/h5u.Grid.Columns.pas` – Th5uGridColumn.getitem: 3 Deklaration(en), 0 Implementierung(en)
- **ERROR** `Source/Common/h5u.Grid.Columns.pas` – Th5uGridColumn.setitem: 1 Deklaration(en), 0 Implementierung(en)
- **ERROR** `Source/Common/h5u.Grid.Columns.pas` – Th5uGridColumn.update: 1 Deklaration(en), 0 Implementierung(en)
- **ERROR** `Source/Common/h5u.Grid.Columns.pas` – Th5uGridColumn.add: 3 Deklaration(en), 0 Implementierung(en)
- **ERROR** `Source/Common/h5u.Grid.Columns.pas` – Th5uGridColumn.findbyid: 1 Deklaration(en), 0 Implementierung(en)
- **ERROR** `Source/Common/h5u.Grid.Columns.pas` – Th5uGridColumn.findbyfieldname: 1 Deklaration(en), 0 Implementierung(en)
- **ERROR** `Source/Common/h5u.Grid.Columns.pas` – Th5uGridColumn.visiblecolumns: 1 Deklaration(en), 0 Implementierung(en)
- **ERROR** `Source/Common/h5u.Grid.Columns.pas` – Th5uGridColumn.normalizevisibleindexes: 1 Deklaration(en), 0 Implementierung(en)
- **ERROR** `Source/Common/h5u.Grid.Columns.pas` – Th5uGridColumn.movecolumn: 1 Deklaration(en), 0 Implementierung(en)
- **ERROR** `Source/Common/h5u.Grid.Columns.pas` – Th5uGridColumn.setcells: 1 Deklaration(en), 0 Implementierung(en)
- **ERROR** `Source/Common/h5u.Grid.Columns.pas` – Th5uGridColumn.setrowcount: 1 Deklaration(en), 0 Implementierung(en)
- **ERROR** `Source/Common/h5u.Grid.Columns.pas` – Th5uGridColumn.destroy: 1 Deklaration(en), 0 Implementierung(en)
- **ERROR** `Source/Common/h5u.Grid.Columns.pas` – Th5uGridColumn.findstyle: 1 Deklaration(en), 0 Implementierung(en)
- **ERROR** `Source/FMX/FMX.h5u.Grid.pas` – Th5uFmxGrid.empty: 1 Deklaration(en), 0 Implementierung(en)
- **ERROR** `Source/FMX/FMX.h5u.Grid.pas` – Th5uFmxGrid.paintdefault: 3 Deklaration(en), 0 Implementierung(en)
- **ERROR** `Source/FMX/FMX.h5u.Grid.pas` – Th5uFmxGrid.bindcell: 1 Deklaration(en), 0 Implementierung(en)
- **ERROR** `Source/FMX/FMX.h5u.Grid.pas` – Th5uFmxGrid.paint: 2 Deklaration(en), 1 Implementierung(en)
- **ERROR** `Source/FMX/FMX.h5u.Grid.pas` – Th5uFmxGrid.ensurebitmap: 1 Deklaration(en), 0 Implementierung(en)
- **ERROR** `Source/FMX/FMX.h5u.Grid.pas` – Th5uFmxGrid.destroy: 2 Deklaration(en), 1 Implementierung(en)

> Der Audit ist compilerunabhängig und ersetzt keinen DCC-/IDE-Build. Versionsabhängige VCL-/FMX-API-Unterschiede können nur mit der Zielversion abschließend geprüft werden.
