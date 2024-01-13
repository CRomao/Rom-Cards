unit View.ExitGame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FMX.Objects, FMX.Controls.Presentation, FMX.Ani;

type
  TViewExitGame = class(TFrame)
    lytContainer: TLayout;
    Rectangle1: TRectangle;
    lytOptions: TLayout;
    rtgOptions: TRectangle;
    lblTitle: TLabel;
    rtgNo: TRectangle;
    lblNo: TLabel;
    rtgYes: TRectangle;
    lblYes: TLabel;
    Animation: TFloatAnimation;
    procedure rtgYesClick(Sender: TObject);
    procedure AnimationFinish(Sender: TObject);
    procedure rtgNoClick(Sender: TObject);
  private
    { Private declarations }
    FCloseAnimation, FCloseAnimationGame: Boolean;
  public
    { Public declarations }
  end;

implementation

{$R *.fmx}

procedure TViewExitGame.AnimationFinish(Sender: TObject);
begin
  if FCloseAnimation then
  begin
    Self.Free;
  end
  else
  if FCloseAnimationGame then
  begin
    TForm(Self.Parent).Close;
  end
  else
  begin
    lblTitle.Visible:= True;
    rtgNo.Visible:= True;
    rtgYes.Visible:= True;
  end;
end;

procedure TViewExitGame.rtgNoClick(Sender: TObject);
begin
  Animation.Enabled:= False;
  FCloseAnimation:= True;
  lblTitle.Visible:= False;
  rtgNo.Visible:= False;
  rtgYes.Visible:= False;
  Animation.Inverse:= True;
  Animation.Enabled:= True;
end;

procedure TViewExitGame.rtgYesClick(Sender: TObject);
begin
  Animation.Enabled:= False;
  FCloseAnimationGame:= True;
  lblTitle.Visible:= False;
  rtgNo.Visible:= False;
  rtgYes.Visible:= False;
  Animation.Inverse:= True;
  Animation.Enabled:= True;
end;

end.
