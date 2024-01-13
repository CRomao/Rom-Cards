unit View.AboutGame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Objects, FMX.Layouts, FMX.Ani;

type
  TViewAboutGame = class(TFrame)
    lytContainer: TLayout;
    rtgContainer: TRectangle;
    lytOptions: TLayout;
    rtgOptions: TRectangle;
    lblTitle: TLabel;
    lblNameDeveloper: TLabel;
    Layout1: TLayout;
    rtgTopClose: TRectangle;
    Rectangle9: TRectangle;
    rtgClose: TRectangle;
    imgClose: TImage;
    Animation: TFloatAnimation;
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

procedure TViewAboutGame.AnimationFinish(Sender: TObject);
begin
  if FCloseAnimation then
  begin
    Self.Free;
  end
  else
  begin
    lblTitle.Visible:= True;
    lblNameDeveloper.Visible:= True;
  end;
end;

procedure TViewAboutGame.imgCloseClick(Sender: TObject);
begin
  Animation.Enabled:= False;
  FCloseAnimation:= True;
  lblTitle.Visible:= False;
  lblNameDeveloper.Visible:= False;
  Animation.Inverse:= True;
  Animation.Enabled:= True;
end;

end.
