unit View.MenuPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Layouts, FMX.Controls.Presentation, FMX.StdCtrls, Winapi.Windows,
  System.ImageList, FMX.ImgList, FMX.Ani, FMX.Memo.Types, FMX.ScrollBox,
  FMX.Memo, FMX.Media, FMX.Platform.Win;

type
  TViewMenuPrincipal = class(TForm)
    Layout1: TLayout;
    Rectangle1: TRectangle;
    Layout2: TLayout;
    rtgNewGame: TRectangle;
    Label1: TLabel;
    rtgRanking: TRectangle;
    Label3: TLabel;
    rtgHowToPlay: TRectangle;
    Label4: TLabel;
    rtgExit: TRectangle;
    Label2: TLabel;
    Layout3: TLayout;
    Layout4: TLayout;
    Rectangle7: TRectangle;
    Layout5: TLayout;
    Rectangle8: TRectangle;
    rtgTopBorder: TRectangle;
    Rectangle9: TRectangle;
    Rectangle11: TRectangle;
    imgClose: TImage;
    imgMinimize: TImage;
    imgInformation: TImage;
    rtgAnimationNewGame: TRectangle;
    AnimationNewGame: TFloatAnimation;
    lytContainer: TLayout;
    rtgStack1: TRectangle;
    rtgStack2: TRectangle;
    rtgStack3: TRectangle;
    rtgStack4: TRectangle;
    rtgStack5: TRectangle;
    rtgStack6: TRectangle;
    rtgStack7: TRectangle;
    lytLeft: TLayout;
    rtgLeft: TRectangle;
    imgUndo: TImage;
    rtgDiscard: TRectangle;
    rtgStock: TRectangle;
    imgRefreshStock: TImage;
    imgTip: TImage;
    lytRight: TLayout;
    rtgRight: TRectangle;
    imgAssemblyClub: TImage;
    imgAssemblySpade: TImage;
    imgAssemblyDiamond: TImage;
    imgAssemblyHeart: TImage;
    Button1: TButton;
    mmo: TMemo;
    procedure imgCloseClick(Sender: TObject);
    procedure imgMinimizeClick(Sender: TObject);
    procedure rtgNewGameClick(Sender: TObject);
    procedure rtgExitClick(Sender: TObject);
    procedure imgInformationClick(Sender: TObject);
    procedure AnimationNewGameFinish(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure rtgHowToPlayClick(Sender: TObject);
    procedure rtgTopBorderMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure rtgRankingClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

const
  WM_SYSCOMMAND = $0112;
  SC_DRAGMOVE = $F012;

var
  ViewMenuPrincipal: TViewMenuPrincipal;

implementation

uses

  View.Principal, View.AboutGame, Provider.Loading, View.HowToPlay, View.Ranking;

{$R *.fmx}

procedure TViewMenuPrincipal.imgCloseClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TViewMenuPrincipal.imgInformationClick(Sender: TObject);
var
  ViewAboutGame: TViewAboutGame;
begin
  ViewAboutGame:= TViewAboutGame.Create(nil);
  ViewAboutGame.Parent:= ViewMenuPrincipal;
  ViewAboutGame.BringToFront;
  ViewAboutGame.lblTitle.Visible:= False;
  ViewAboutGame.lblNameDeveloper.Visible:= False;
  ViewAboutGame.Animation.Enabled:= True;
end;

procedure TViewMenuPrincipal.imgMinimizeClick(Sender: TObject);
begin
  Self.WindowState:= TWindowState.wsMinimized;
end;

procedure TViewMenuPrincipal.rtgExitClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TViewMenuPrincipal.rtgHowToPlayClick(Sender: TObject);
var
  LViewHowToPlay: TViewHowToPlay;
begin
  LViewHowToPlay:= TViewHowToPlay.Create(ViewMenuPrincipal);
  LViewHowToPlay.SetConfigInit;
  LViewHowToPlay.Parent:= ViewMenuPrincipal;
  LViewHowToPlay.BringToFront;
  LViewHowToPlay.lytContent.Visible:= False;
  LViewHowToPlay.Animation.Enabled:= True;
end;

procedure TViewMenuPrincipal.rtgNewGameClick(Sender: TObject);
begin
  TLoading.Show(Self, 'Preparando as cartas...');
  AnimationNewGame.start;
end;

procedure TViewMenuPrincipal.rtgRankingClick(Sender: TObject);
var
  LViewRanking: TViewRanking;
begin
  LViewRanking:= TViewRanking.Create(nil);
  LViewRanking.Parent:= ViewMenuPrincipal;
  LViewRanking.BringToFront;
  LViewRanking.lytContent.Visible:= False;
  LViewRanking.Animation.Enabled:= True;
end;

procedure TViewMenuPrincipal.rtgTopBorderMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  SendMessage(FmxHandleToHWND(ViewMenuPrincipal.Handle), WM_SYSCOMMAND, SC_DRAGMOVE, 0);
end;

procedure TViewMenuPrincipal.AnimationNewGameFinish(Sender: TObject);
begin
  ViewMenuPrincipal.AnimationNewGame.Inverse:= not ViewMenuPrincipal.AnimationNewGame.Inverse;
  if (AnimationNewGame.Tag = 0) then
  begin
    ViewPrincipal:= TViewPrincipal.Create(nil);
    AnimationNewGame.Tag:= 1;
    try
      ViewMenuPrincipal.Visible:= False;
      ViewPrincipal.ShowModal;
    finally
      ViewPrincipal.Free;
      ViewMenuPrincipal.Visible:= True;
    end;
  end
  else
  begin
    AnimationNewGame.Tag:= 0;
    rtgAnimationNewGame.Position.Y:= rtgAnimationNewGame.Position.Y + 20;
  end;

end;

procedure TViewMenuPrincipal.FormCreate(Sender: TObject);
begin
  rtgAnimationNewGame.Position.Y:= rtgAnimationNewGame.Position.Y + 50;
end;

end.
