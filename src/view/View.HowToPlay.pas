unit View.HowToPlay;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Ani, FMX.Objects, FMX.Controls.Presentation, FMX.Layouts, FMX.TabControl;

type
  TViewHowToPlay = class(TFrame)
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
    tbcHowToPlay: TTabControl;
    lytNextPage: TLayout;
    rtgNext: TRectangle;
    rtgPrevious: TRectangle;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    tbiFirst: TTabItem;
    tbiSecond: TTabItem;
    tbiThird: TTabItem;
    tbiFourth: TTabItem;
    tbiFifth: TTabItem;
    Image1: TImage;
    lblFirst: TLabel;
    lblSecond: TLabel;
    imgSecond: TImage;
    lblThird: TLabel;
    lblFourth: TLabel;
    imgFourth: TImage;
    lblFifth: TLabel;
    imgFifth: TImage;
    tbiSixth: TTabItem;
    lblSixth: TLabel;
    imgSixth: TImage;
    tbiSeventh: TTabItem;
    lblSeventh: TLabel;
    procedure AnimationFinish(Sender: TObject);
    procedure imgCloseClick(Sender: TObject);
    procedure rtgNextClick(Sender: TObject);
    procedure rtgPreviousClick(Sender: TObject);
  private
    { Private declarations }
    FCloseAnimation: Boolean;
    FTabIndex: integer;
  public
    { Public declarations }
    procedure SetConfigInit;
  end;

implementation

{$R *.fmx}

procedure TViewHowToPlay.AnimationFinish(Sender: TObject);
begin
  if FCloseAnimation then
  begin
    Self.Free;
  end
  else
  begin
    lytContent.Visible:= True;
  end;
end;

procedure TViewHowToPlay.imgCloseClick(Sender: TObject);
begin
  Animation.Enabled:= False;
  FCloseAnimation:= True;
  lytContent.Visible:= False;
  Animation.Inverse:= True;
  Animation.Enabled:= True;
end;

procedure TViewHowToPlay.rtgNextClick(Sender: TObject);
begin
  if not (FTabIndex = 6) then
  begin
    FTabIndex:= FTabIndex + 1;
    tbcHowToPlay.GotoVisibleTab(FTabIndex);
    rtgPrevious.Visible:= True;
    rtgNext.Visible:= True;
  end;

  if (FTabIndex = 6) then
    rtgNext.Visible:= False;
end;

procedure TViewHowToPlay.rtgPreviousClick(Sender: TObject);
begin
  if not (FTabIndex = 0) then
  begin
    FTabIndex:= FTabIndex - 1;
    tbcHowToPlay.GotoVisibleTab(FTabIndex);
    rtgPrevious.Visible:= True;
    rtgNext.Visible:= True;
  end;

  if (FTabIndex = 0) then
    rtgPrevious.Visible:= False;
end;

procedure TViewHowToPlay.SetConfigInit;
begin
  tbcHowToPlay.GotoVisibleTab(0);
  rtgPrevious.Visible:= False;
  FTabIndex:= 0;
end;



end.
