unit ZEEdU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, StdCtrls, ExtCtrls, CheckLst, ComCtrls, Spin;

type
  TfmZEEdMain = class(TForm)
    titleEntities: TLabel;
    lbEntities: TListBox;
    Bevel1: TBevel;
    Bevel2: TBevel;
    sbtnLoadFolder: TSpeedButton;
    Bevel3: TBevel;
    clbOrientations: TCheckListBox;
    titleOrientations: TLabel;
    Bevel4: TBevel;
    ledActiveFolder: TLabeledEdit;
    sbMain: TStatusBar;
    Bevel5: TBevel;
    lbStates: TListBox;
    titleStates: TLabel;
    sedXSpan: TSpinEdit;
    titleX: TLabel;
    sedYSpan: TSpinEdit;
    titleY: TLabel;
    titleDimensions: TLabel;
    ledBaseSpriteName: TLabeledEdit;
    titleImagesCount: TLabel;
    titleFramesCount: TLabel;
    cbRepeats: TCheckBox;
    ledNameOfNextSequence: TLabeledEdit;
    sedImageCount: TSpinEdit;
    sedFrameCount: TSpinEdit;
    Bevel6: TBevel;
    Bevel7: TBevel;
    Bevel8: TBevel;
    lbSequenceFrames: TListBox;
    titleSequenceFrames: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fmZEEdMain: TfmZEEdMain;

implementation

{$R *.dfm}

end.
