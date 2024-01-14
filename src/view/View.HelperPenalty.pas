unit View.HelperPenalty;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Ani, FMX.Objects, FMX.Controls.Presentation, FMX.Layouts;

type
  TViewHelperPenalty = class(TFrame)
    lytContainer: TLayout;
    rtgContainer: TRectangle;
    lytOptions: TLayout;
    rtgOptions: TRectangle;
    Layout1: TLayout;
    rtgTopClose: TRectangle;
    Rectangle9: TRectangle;
    rtgClose: TRectangle;
    imgClose: TImage;
    Animation: TFloatAnimation;
    lytContents: TLayout;
    lblTitle: TLabel;
    lblObs1: TLabel;
    lblObs2: TLabel;
    procedure imgCloseClick(Sender: TObject);
    procedure AnimationFinish(Sender: TObject);
  private
    { Private declarations }
    FCloseAnimation: Boolean;
  public
    { Public declarations }
  end;

implementation

{$R *.fmx}

procedure TViewHelperPenalty.AnimationFinish(Sender: TObject);
begin
  if FCloseAnimation then
    Self.Free
  else
    lytContents.Visible:= True;
end;

procedure TViewHelperPenalty.imgCloseClick(Sender: TObject);
begin
  Animation.Enabled:= False;
  FCloseAnimation:= True;
  lytContents.Visible:= False;
  Animation.Inverse:= True;
  Animation.Enabled:= True;
end;

end.
