unit View.PauseGame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Ani, FMX.Controls.Presentation, FMX.Layouts;

type
  TViewPauseGame = class(TFrame)
    lytContainer: TLayout;
    rtgContainer: TRectangle;
    lytOptions: TLayout;
    rtgOptions: TRectangle;
    Layout1: TLayout;
    rtgTopClose: TRectangle;
    Rectangle9: TRectangle;
    rtgClose: TRectangle;
    lytContent: TLayout;
    rtgBackToGame: TRectangle;
    lblNo: TLabel;
    Animation: TFloatAnimation;
    lblTitle: TLabel;
    procedure AnimationFinish(Sender: TObject);
    procedure rtgBackToGameClick(Sender: TObject);
  private
    { Private declarations }
    FCloseAnimation: Boolean;
  public
    { Public declarations }
  end;

implementation

uses
  View.Principal;

{$R *.fmx}

procedure TViewPauseGame.AnimationFinish(Sender: TObject);
begin
  if FCloseAnimation then
  begin
    ViewPrincipal.Timer.Enabled:= True;
    Self.Free;
  end
  else
    lytContent.Visible:= True;
end;

procedure TViewPauseGame.rtgBackToGameClick(Sender: TObject);
begin
  Animation.Enabled:= False;
  FCloseAnimation:= True;
  lytContent.Visible:= False;
  Animation.Inverse:= True;
  Animation.Enabled:= True;
end;

end.
