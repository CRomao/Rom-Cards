unit View.Principal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Layouts, FMX.ExtCtrls, FMX.Controls.Presentation, FMX.StdCtrls,
  FMX.Effects, FMX.Ani,System.Generics.Collections,Controller.Cards,
  Model.Card, Model.Stack, Controller.Stacks, FMX.Memo.Types, FMX.ScrollBox,
  FMX.Memo, View.MenuPrincipal, FMX.Platform.Win, WinAPI.Windows;

type
  TViewPrincipal = class(TForm)
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
    lytRight: TLayout;
    rtgRight: TRectangle;
    imgAssemblyClub: TImage;
    imgAssemblySpade: TImage;
    imgAssemblyDiamond: TImage;
    imgAssemblyHeart: TImage;
    imgUndo: TImage;
    rtgDiscard: TRectangle;
    rtgStock: TRectangle;
    Layout3: TLayout;
    rtgTopBorder: TRectangle;
    Rectangle9: TRectangle;
    imgMinimize: TImage;
    Rectangle11: TRectangle;
    imgClose: TImage;
    imgTip: TImage;
    imgRefreshStock: TImage;
    Timer: TTimer;
    lblTimerGame: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    imgMenu: TImage;
    Label4: TLabel;
    imgHelpPenalty: TImage;
    procedure FormCreate(Sender: TObject);
    procedure imgRefreshStockClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure imgUndoClick(Sender: TObject);
    procedure imgCloseClick(Sender: TObject);
    procedure imgMinimizeClick(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure rtgTopBorderMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure imgTipClick(Sender: TObject);
    procedure imgMenuClick(Sender: TObject);
    procedure imgHelpPenaltyClick(Sender: TObject);
  private
    procedure ReporEstoque(AOriginStackType, ADestinyStackType: TStackType; SpecialMovement: Boolean);
    procedure OnFinishAnimation(Sender: TObject);
    procedure GetTipCard;
    procedure UndoMovement;
    procedure ExitGame;
    procedure PauseGame;
    { Private declarations }
  public
    { Public declarations }
    FTempoCronometro, FHoras, FMinutos, FSegundos: integer;
    FTempoCronometroText: string;
    FPausedGame, FViewTipVisible, FUndoInProcess: Boolean;
    FNumberOfTipsUsed, FNumberOfMovementsUndone: Integer;
    procedure CalculatedTimeRunning;
  end;

const
  WM_SYSCOMMAND = $0112;
  SC_DRAGMOVE = $F012;

var
  ViewPrincipal: TViewPrincipal;

implementation

uses
  View.ExitGame, View.Tip, Provider.Loading, Provider.Functions, View.PauseGame, View.HelperPenalty, Model.Movement, Controller.Movement;

{$R *.fmx}

procedure TViewPrincipal.FormClose(Sender: TObject; var Action: TCloseAction);   
begin
  CloseGame;
  ViewMenuPrincipal.AnimationNewGame.Start;
end;

procedure TViewPrincipal.FormCreate(Sender: TObject);
begin
  InitGame;

  SplitCardsToStack(rtgStack1, 0);
  SplitCardsToStack(rtgStack2, 1);
  SplitCardsToStack(rtgStack3, 2);
  SplitCardsToStack(rtgStack4, 3);
  SplitCardsToStack(rtgStack5, 4);
  SplitCardsToStack(rtgStack6, 5);
  SplitCardsToStack(rtgStack7, 6);
  SplitCardsToStack(rtgStock,  7);
  SplitCardsToStack(rtgDiscard, 8);
  SplitCardsToStack(imgAssemblyHeart, 9);
  SplitCardsToStack(imgAssemblyDiamond, 10);
  SplitCardsToStack(imgAssemblyClub, 11);
  SplitCardsToStack(imgAssemblySpade, 12);

  TLoading.Hide;

  Timer.Enabled:= True;
  FTempoCronometro:= 0;
  FNumberOfTipsUsed:= 0;
  FNumberOfMovementsUndone:= 0;
end;

procedure TViewPrincipal.FormKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if (Key = VK_ESCAPE) then
    ExitGame;

  if (KeyChar = ' ') and not FPausedGame then
    PauseGame;

  if (UpperCase(KeyChar) = 'F' ) and not FViewTipVisible then
    GetTipCard;

  if (UpperCase(KeyChar) = 'D' ) and not FUndoInProcess then
    UndoMovement;

  if (UpperCase(KeyChar) = 'R' ) then
    ReporEstoque(tstDiscard, tstStock, False);
end;

procedure TViewPrincipal.PauseGame;
var
  LViewPauseGame: TViewPauseGame;
begin
  FPausedGame:= True;
  LViewPauseGame:= TViewPauseGame.Create(ViewPrincipal);
  LViewPauseGame.Parent:= ViewPrincipal;
  LViewPauseGame.BringToFront;
  LViewPauseGame.lytContent.Visible:= False;
  Timer.Enabled:= False;
  LViewPauseGame.Animation.Enabled:= True;
end;

procedure TViewPrincipal.imgCloseClick(Sender: TObject);
begin
  ExitGame;
end;

procedure TViewPrincipal.imgHelpPenaltyClick(Sender: TObject);
var
  LViewHelperPenalty: TViewHelperPenalty;
begin
  LViewHelperPenalty:= TViewHelperPenalty.Create(nil);
  LViewHelperPenalty.Parent:= ViewPrincipal;
  LViewHelperPenalty.BringToFront;
  LViewHelperPenalty.lytContents.Visible:= False;
  LViewHelperPenalty.Animation.Enabled:= True;
end;

procedure TViewPrincipal.ExitGame;
var
  ViewExitGame: TViewExitGame;
begin
  ViewExitGame:= TViewExitGame.Create(ViewPrincipal);
  ViewExitGame.Parent:= ViewPrincipal;
  ViewExitGame.BringToFront;
  ViewExitGame.lblTitle.Visible:= False;
  ViewExitGame.rtgNo.Visible:= False;
  ViewExitGame.rtgYes.Visible:= False;
  ViewExitGame.Animation.Enabled:= True;
end;

procedure TViewPrincipal.imgMenuClick(Sender: TObject);
begin
  PauseGame;
end;

procedure TViewPrincipal.imgMinimizeClick(Sender: TObject);
begin
  Self.WindowState:= TWindowState.wsMinimized;
end;

procedure TViewPrincipal.imgRefreshStockClick(Sender: TObject);
begin
  ReporEstoque(tstDiscard, tstStock, False);
end;

procedure TViewPrincipal.imgTipClick(Sender: TObject);
begin
  GetTipCard;
end;

procedure TViewPrincipal.GetTipCard;
var
  ViewTip: TViewTip;
  LTip: TList<string>;
begin
  LTip:= TControllerStacks.GetTip;

  if (LTip.Count = 0) then
  begin
    TLoading.ToastMessage(Self, 'Sem dicas no momento...', TAlignLayout.Bottom, $FF5E5E5E, $FFFFFFFF, 2);
    LTip.Free;
  end
  else
  begin
    Inc(FNumberOfTipsUsed);
    FViewTipVisible:= True;
    ViewTip:= TViewTip.Create(ViewPrincipal);
    ViewTip.Parent:= ViewPrincipal;
    ViewTip.BringToFront;
    ViewTip.lblTitle.Visible:= False;
    ViewTip.lytCards.Visible:= False;
    ViewTip.SetImageCards(LTip);
    ViewTip.Animation.Enabled:= True;
  end;
end;

procedure TViewPrincipal.imgUndoClick(Sender: TObject);
begin
  UndoMovement;
end;

procedure TViewPrincipal.UndoMovement;
var
  LLastCardMoved, aux: TModelCard;
  LLastMovement: TModelMovement;
  LAnimationX, LAnimationY: TFloatAnimation;
begin
  if (TControllerMovement.GetInstance.Count > 1) then
  begin
    Inc(FNumberOfMovementsUndone);
    imgUndo.Enabled:= False;
    FUndoInProcess:= True;
    if TControllerMovement.GetLastMovement.SPECIAL_MOVEMENT then
    begin
      try
        ReporEstoque(tstStock, tstDiscard, True);
        TControllerMovement.GetInstance.Items[Pred(TControllerMovement.GetInstance.Count)].DisposeOf;
        TControllerMovement.GetInstance.Delete(Pred(TControllerMovement.GetInstance.Count));
      finally
        imgUndo.Enabled:= True;
        FUndoInProcess:= False;
      end;
    end
    else
    begin
      LLastCardMoved:= TControllerMovement.GetLastCardMoved;
      LLastMovement:= TControllerMovement.GetLastMovement;

      {
        adjust the previous and the next card for the card moved
      }
      LLastCardMoved.PREVIOUS_CARD.NEXT_CARD:= nil;
      LLastMovement.PREVIOUS_CARD.NEXT_CARD:= nil;

      LLastCardMoved.Align:= TAlignLayout.None;
      LLastCardMoved.Parent:= lytContainer;

      LLastCardMoved.STACK_TYPE:= LLastMovement.ORIGIN_STACK_TYPE;
      LLastCardMoved.PREVIOUS_CARD:=  LLastMovement.PREVIOUS_CARD;

      LLastMovement.PREVIOUS_CARD.NEXT_CARD:= LLastCardMoved;

      //ajustar o id da pilha das cartas acima da carta que acabou de ser movida;
      aux:= LLastCardMoved;
      while (aux <> nil) do
      begin
        aux.STACK_TYPE:= LLastMovement.ORIGIN_STACK_TYPE;
        aux:= aux.NEXT_CARD;
      end;

      {try the animation move the card}
      LAnimationX:= TFloatAnimation.Create(nil);
      LAnimationY:= TFloatAnimation.Create(nil);
      try
        LLastCardMoved.AddObject(LAnimationX);
        LLastCardMoved.AddObject(LAnimationY);

        LAnimationX.AnimationType:= TAnimationType.InOut;
        LAnimationX.Interpolation:= TInterpolationType.Linear;
        LAnimationX.Duration:= 0.3;
        LAnimationX.PropertyName:= 'Position.X';

        LAnimationY.AnimationType:= TAnimationType.InOut;
        LAnimationY.Duration:= 0.3;
        LAnimationY.Interpolation:= TInterpolationType.Linear;
        LAnimationY.PropertyName:= 'Position.Y';


        LAnimationX.OnFinish:= OnFinishAnimation;
        //LAnimationY.OnFinish:= OnFinishAnimation;

        {define the position the card with base the position os stack}

        {         ***possibles moves***

            1-stack for stack = do not verify
            2-assembly for stack
            3-discard for stock
            4-stack for discard
            5-assembly for discard
            6-stack for assembly

        }

        {1-stack for stack}
        if (LLastMovement.DESTINY_STACK_TYPE in [tstStack1, tstStack2, tstStack3, tstStack4, tstStack5, tstStack6, tstStack7]) and
           (LLastMovement.ORIGIN_STACK_TYPE in [tstStack1, tstStack2, tstStack3, tstStack4, tstStack5, tstStack6, tstStack7]) then
        begin
          LAnimationX.StartValue:= TRectangle(TControllerStacks.GetStack(LLastMovement.DESTINY_STACK_TYPE).CARD.Parent).Position.X;
          LAnimationX.StopValue:= TRectangle(TControllerStacks.GetStack(LLastMovement.ORIGIN_STACK_TYPE).CARD.Parent).Position.X;

          LAnimationY.StartValue:= TControllerStacks.GetTotalCardsStack(LLastMovement.DESTINY_STACK_TYPE) * 23;
          LAnimationY.StopValue:= (TControllerStacks.GetTotalCardsStack(LLastMovement.ORIGIN_STACK_TYPE)-1) * 22;
        end
        else {2-assembly for stack}
        if (LLastMovement.DESTINY_STACK_TYPE in [tstAssemblyHeart, tstAssemblyDiamond, tstAssemblyClub, tstAssemblySpade]) and
           (LLastMovement.ORIGIN_STACK_TYPE in [tstStack1, tstStack2, tstStack3, tstStack4, tstStack5, tstStack6, tstStack7]) then
        begin
          LAnimationX.StartValue:= 567;
          LAnimationX.StopValue:= TRectangle(TControllerStacks.GetStack(LLastMovement.ORIGIN_STACK_TYPE).CARD.Parent).Position.X;


          {verify the position Y for each assembly}
          case LLastMovement.DESTINY_STACK_TYPE of
            tstAssemblyHeart: LAnimationY.StartValue:= 20;
            tstAssemblyDiamond: LAnimationY.StartValue:= 115;
            tstAssemblyClub: LAnimationY.StartValue:= 210;
            tstAssemblySpade: LAnimationY.StartValue:= 305;
          end;

          LAnimationY.StopValue:= (TControllerStacks.GetTotalCardsStack(LLastMovement.ORIGIN_STACK_TYPE)-1) * 22;
        end
        else{6-stack for assembly}
        if (LLastMovement.DESTINY_STACK_TYPE in [tstStack1, tstStack2, tstStack3, tstStack4, tstStack5, tstStack6, tstStack7]) and
           (LLastMovement.ORIGIN_STACK_TYPE in [tstAssemblyHeart, tstAssemblyDiamond, tstAssemblyClub, tstAssemblySpade]) then
        begin
          LAnimationX.StartValue:= TRectangle(TControllerStacks.GetStack(LLastMovement.DESTINY_STACK_TYPE).CARD.Parent).Position.X;
          LAnimationX.StopValue:= 567;

          LAnimationY.StartValue:= TControllerStacks.GetTotalCardsStack(LLastMovement.DESTINY_STACK_TYPE) * 23;
          {verify the position Y for each assembly}
          case LLastMovement.ORIGIN_STACK_TYPE of
            tstAssemblyHeart: LAnimationY.StopValue:= 20;
            tstAssemblyDiamond: LAnimationY.StopValue:= 115;
            tstAssemblyClub: LAnimationY.StopValue:= 210;
            tstAssemblySpade: LAnimationY.StopValue:= 305;
          end;
        end
        else {3-discard for stock}
        if (LLastMovement.DESTINY_STACK_TYPE in [tstDiscard]) and (LLastMovement.ORIGIN_STACK_TYPE in [tstStock]) then
        begin
          LAnimationX.StartValue:= 6;
          LAnimationX.StopValue:= TRectangle(TControllerStacks.GetStack(LLastMovement.ORIGIN_STACK_TYPE).CARD.Parent).Position.X;

          LAnimationY.StartValue:= 115;
          LAnimationY.StopValue:= 20;

          LLastCardMoved.Bitmap.LoadFromFile(LLastCardMoved.IMAGE_CARD_DEFAULT_LOCATION);
        end
        else {4-stack for discard}
        if (LLastMovement.DESTINY_STACK_TYPE in [tstStack1, tstStack2, tstStack3, tstStack4, tstStack5, tstStack6, tstStack7]) and
           (LLastMovement.ORIGIN_STACK_TYPE in [tstDiscard]) then
        begin
          LAnimationX.StartValue:= TRectangle(TControllerStacks.GetStack(LLastMovement.DESTINY_STACK_TYPE).CARD.Parent).Position.X;
          LAnimationX.StopValue:= 6;

          LAnimationY.StartValue:= TControllerStacks.GetTotalCardsStack(LLastMovement.DESTINY_STACK_TYPE) * 23;
          LAnimationY.StopValue:= 115;
        end
        else {5-assembly for discard}
        if (LLastMovement.DESTINY_STACK_TYPE in [tstAssemblyHeart, tstAssemblyDiamond, tstAssemblyClub, tstAssemblySpade]) and (LLastMovement.ORIGIN_STACK_TYPE in [tstDiscard]) then
        begin
          LAnimationX.StartValue:= 567;
          LAnimationY.StopValue:= 6;

          {verify the position Y for each assembly}
          case LLastMovement.DESTINY_STACK_TYPE of
            tstAssemblyHeart: LAnimationY.StartValue:= 20;
            tstAssemblyDiamond: LAnimationY.StartValue:= 115;
            tstAssemblyClub: LAnimationY.StartValue:= 210;
            tstAssemblySpade: LAnimationY.StartValue:= 305;
          end;
          LAnimationY.StopValue:= 115;
        end;

        LAnimationX.Enabled:= True;
        LAnimationY.Enabled:= True;
      finally
        //LAnimationX.DisposeOf;
        //LAnimationY.DisposeOf;
        imgUndo.Enabled:= True;
      end;
    end;
  end;

end;

procedure TViewPrincipal.OnFinishAnimation(Sender: TObject);
begin
  try
    TControllerMovement.GetLastCardMoved.Parent:= TControllerMovement.GetLastCardMoved.PREVIOUS_CARD;
    TControllerMovement.GetLastCardMoved.PREVIOUS_CARD.AddObject(TControllerMovement.GetLastCardMoved);

    TControllerMovement.GetLastCardMoved.Align:= TAlignLayout.Top;

    if not TControllerMovement.GetLastMovement.PREVIOUS_CARD_VISIBLE and (TControllerMovement.GetLastMovement.PREVIOUS_CARD.VALUE > 0) then
    begin
      TControllerMovement.GetLastMovement.PREVIOUS_CARD.Bitmap.LoadFromFile(TControllerMovement.GetLastMovement.PREVIOUS_CARD.IMAGE_CARD_DEFAULT_LOCATION);
      TControllerMovement.GetLastCardMoved.PREVIOUS_CARD.VISIBLE:= False;
    end;

    {teste - aplicar padding de acordo com a pilha que a carta vai ficars}
    case TControllerMovement.GetLastCardMoved.STACK_TYPE of
      tstStack1, tstStack2, tstStack3, tstStack4, tstStack5, tstStack6, tstStack7:
      begin
        TControllerMovement.GetLastCardMoved.Padding.Top:= 23;
        if not (TControllerMovement.GetLastCardMoved.PREVIOUS_CARD = nil) and
        (TControllerMovement.GetLastCardMoved.PREVIOUS_CARD.VALUE <> 0) then
          TControllerMovement.GetLastCardMoved.PREVIOUS_CARD.Padding.Top:= 23;
      end
      else
      begin
        TControllerMovement.GetLastCardMoved.Padding.Top:= 0;
        if not (TControllerMovement.GetLastCardMoved.PREVIOUS_CARD = nil) then
          TControllerMovement.GetLastCardMoved.PREVIOUS_CARD.Padding.Top:= 0;
      end;
    end;
   {teste}

    TControllerMovement.GetInstance.Items[Pred(TControllerMovement.GetInstance.Count)].DisposeOf;
    TControllerMovement.GetInstance.Delete(Pred(TControllerMovement.GetInstance.Count));

    TControllerMovement.SetLastCardMoved(TControllerMovement.GetLastMovement.CARD);
  finally
    imgUndo.Enabled:= True;
    FUndoInProcess:= False;
  end;
end;

procedure TViewPrincipal.ReporEstoque(AOriginStackType, ADestinyStackType: TStackType; SpecialMovement: Boolean);
var
  reporEstoque, estoqueFinal: TModelCard;
  tam, I: integer;
  LMovement: TModelMovement;
begin
  if ((TControllerStacks.GetInstance.Items[Ord(ADestinyStackType)].CARD.NEXT_CARD = nil) and not (TControllerStacks.GetInstance.Items[Ord(AOriginStackType)].CARD.NEXT_CARD = nil)) then
  begin
    tam:= TControllerStacks.GetTotalCardsStack(AOriginStackType);

    for I := 0 to tam-1 do
    begin
      reporEstoque:= TControllerStacks.GetLastCardStack(AOriginStackType);
      estoqueFinal:= TControllerStacks.GetLastCardStack(ADestinyStackType);

      reporEstoque.PREVIOUS_CARD.NEXT_CARD:= nil;
      reporEstoque.PREVIOUS_CARD:= estoqueFinal;
      estoqueFinal.NEXT_CARD:= reporEstoque;

      estoqueFinal.AddObject(reporEstoque);
      reporEstoque.STACK_TYPE:= ADestinyStackType;

      if not SpecialMovement then
        reporEstoque.Bitmap.LoadFromFile(reporEstoque.IMAGE_CARD_DEFAULT_LOCATION)
      else
        reporEstoque.Bitmap.LoadFromFile(reporEstoque.IMAGE_CARD_LOCATION);

      TControllerMovement.SetLastCardMoved(reporEstoque);
    end;

    if not SpecialMovement then
    begin
      LMovement:= TModelMovement.Create;
      LMovement.PREVIOUS_MOVEMENT:= TControllerMovement.GetInstance.Items[Pred(TControllerMovement.GetInstance.Count)];
      LMovement.HEAD_STACK_MOVEMENT:= False;
      LMovement.NEXT_MOVIMENT:= nil;
      LMovement.PREVIOUS_CARD_VISIBLE:= false;
      LMovement.CARD:= nil;
      LMovement.PREVIOUS_CARD:= nil;
      LMovement.SPECIAL_MOVEMENT:= True;
      LMovement.ORIGIN_STACK_TYPE:= AOriginStackType;
      LMovement.DESTINY_STACK_TYPE:= ADestinyStackType;

      TControllerMovement.SetMovement(LMovement);
    end;
  end;
end;

procedure TViewPrincipal.rtgTopBorderMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  SendMessage(FmxHandleToHWND(ViewPrincipal.Handle), WM_SYSCOMMAND, SC_DRAGMOVE, 0);
end;

procedure TViewPrincipal.TimerTimer(Sender: TObject);
begin
  Inc(FTempoCronometro);
  CalculatedTimeRunning;
  lblTimerGame.Text:= 'Tempo: ' + FTempoCronometroText;
end;

procedure TViewPrincipal.CalculatedTimeRunning;
begin
  FHoras := FTempoCronometro div 3600;
  FMinutos := (FTempoCronometro div 60) mod 60;
  FSegundos := FTempoCronometro mod 60;
  FTempoCronometroText:= Format('%.2d:%.2d:%.2d', [FHoras, FMinutos, FSegundos]);
end;

end.
