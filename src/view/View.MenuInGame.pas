unit View.MenuInGame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Ani, FMX.Objects, FMX.Controls.Presentation, FMX.Layouts;

type
  TViewMenuInGame = class(TFrame)
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
    lytContent: TLayout;
    rtgNewGame: TRectangle;
    lblNo: TLabel;
    swtMusic: TSwitch;
    Label2: TLabel;
    procedure AnimationFinish(Sender: TObject);
    procedure imgCloseClick(Sender: TObject);
    procedure rtgNewGameClick(Sender: TObject);
    procedure swtMusicClick(Sender: TObject);
  private
    { Private declarations }
    FCloseAnimation: Boolean;
    procedure CloseAll;
    procedure CleanTableGame;
  public
    { Public declarations }
  end;

implementation

uses
  Provider.Functions, View.Principal, View.MenuPrincipal;

{$R *.fmx}

procedure TViewMenuInGame.AnimationFinish(Sender: TObject);
begin
  if FCloseAnimation then
    Self.Free
  else
    lytContent.Visible:= True;
end;

procedure TViewMenuInGame.imgCloseClick(Sender: TObject);
begin
  CloseAll;
end;

procedure TViewMenuInGame.rtgNewGameClick(Sender: TObject);
begin
  CloseGame;
  CleanTableGame;
  InitGame;

  SplitCardsToStack(ViewPrincipal.rtgStack1, 0);
  SplitCardsToStack(ViewPrincipal.rtgStack2, 1);
  SplitCardsToStack(ViewPrincipal.rtgStack3, 2);
  SplitCardsToStack(ViewPrincipal.rtgStack4, 3);
  SplitCardsToStack(ViewPrincipal.rtgStack5, 4);
  SplitCardsToStack(ViewPrincipal.rtgStack6, 5);
  SplitCardsToStack(ViewPrincipal.rtgStack7, 6);
  SplitCardsToStack(ViewPrincipal.rtgStock,  7);
  SplitCardsToStack(ViewPrincipal.rtgDiscard, 8);
  SplitCardsToStack(ViewPrincipal.imgAssemblyHeart, 9);
  SplitCardsToStack(ViewPrincipal.imgAssemblyDiamond, 10);
  SplitCardsToStack(ViewPrincipal.imgAssemblyClub, 11);
  SplitCardsToStack(ViewPrincipal.imgAssemblySpade, 12);
  ViewPrincipal.FTempoCronometro:= 0;
  ViewPrincipal.Timer.Enabled:= True;
  CloseAll;
end;

procedure TViewMenuInGame.swtMusicClick(Sender: TObject);
begin
  if swtMusic.IsChecked then
  begin
    ViewMenuPrincipal.FImageSongID:= 1;
    ViewMenuPrincipal.ConfigSongState;
  end
  else
  begin
    ViewMenuPrincipal.FImageSongID:= 0;
    ViewMenuPrincipal.ConfigSongState;
  end;
end;

procedure TViewMenuInGame.CloseAll;
begin
  Animation.Enabled:= False;
  FCloseAnimation:= True;
  lytContent.Visible:= False;
  Animation.Inverse:= True;
  Animation.Enabled:= True;
end;

procedure TViewMenuInGame.CleanTableGame;
begin
  ViewPrincipal.rtgStack1.DeleteChildren;
  ViewPrincipal.rtgStack2.DeleteChildren;
  ViewPrincipal.rtgStack3.DeleteChildren;
  ViewPrincipal.rtgStack4.DeleteChildren;
  ViewPrincipal.rtgStack5.DeleteChildren;
  ViewPrincipal.rtgStack6.DeleteChildren;
  ViewPrincipal.rtgStack7.DeleteChildren;
  ViewPrincipal.rtgStock.DeleteChildren;
  ViewPrincipal.rtgDiscard.DeleteChildren;
  ViewPrincipal.imgAssemblyHeart.DeleteChildren;
  ViewPrincipal.imgAssemblyDiamond.DeleteChildren;
  ViewPrincipal.imgAssemblyClub.DeleteChildren;
  ViewPrincipal.imgAssemblySpade.DeleteChildren;
  ViewPrincipal.Timer.Enabled:= False;
end;

end.
