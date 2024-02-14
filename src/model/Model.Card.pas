unit Model.Card;

interface

uses
  FMX.Objects,
  System.Generics.Collections,
  System.SysUtils,
  System.UITypes,
  FMX.Types,
  System.Types,
  System.Classes,
  FMX.Dialogs;

type
  TSuitCard = (tscHeart, tscDiamond, tscClub, tscSpade, tscNone);

  TColorCard = (tccRed, tccBlack, tccNone);

  TStackType = (tstStack1, tstStack2, tstStack3, tstStack4, tstStack5, tstStack6,
                tstStack7, tstStock, tstDiscard, tstAssemblyHeart, tstAssemblyDiamond,
                tstAssemblyClub, tstAssemblySpade);

  TModelCard = class(TImage)
    private
    FVALUE: Integer;
    FSUIT_CARD: TSuitCard;
    FVISIBLE: Boolean;
    FCOLOR: TColorCard;
    FPREVIOUS_CARD: TModelCard;
    FNEXT_CARD: TModelCard;
    FIMAGE_CARD_LOCATION: string;
    FIMAGE_CARD_DEFAULT_LOCATION: string;
    FSTACK_TYPE: TStackType;
    function MoveStackForStack(ACardMove, ACardReceive:TModelCard): Boolean;
    function MoveStackForAssembly(ACardMove, ACardReceive: TModelCard): Boolean;
    function MoveStockForDiscard(ACardMove, ACardReceive: TModelCard): Boolean;
    function DiscardForStack(ACardMove, ACardReceive: TModelCard): Boolean;
    function DiscardForAssembly(ACardMove, ACardReceive: TModelCard): Boolean;
    procedure RegisterNewMovement(APreviousCardVisible: Boolean; ACardMove,
      ACardReceive: TModelCard);

  protected
    procedure OnDragOverCard(Sender: TObject; const Data: TDragObject;
    const Point: TPointF; var Operation: TDragOperation);
    procedure OnDragDropCard(Sender: TObject; const Data: TDragObject; const Point: TPointF);

    public
      property VALUE: Integer read FVALUE write FVALUE;
      property SUIT_CARD: TSuitCard read FSUIT_CARD write FSUIT_CARD;
      property VISIBLE: Boolean read FVISIBLE write FVISIBLE;
      property COLOR: TColorCard read FCOLOR write FCOLOR;
      property PREVIOUS_CARD: TModelCard read FPREVIOUS_CARD write FPREVIOUS_CARD;
      property NEXT_CARD: TModelCard read FNEXT_CARD write FNEXT_CARD;
      property IMAGE_CARD_LOCATION: string read FIMAGE_CARD_LOCATION write FIMAGE_CARD_LOCATION;
      property IMAGE_CARD_DEFAULT_LOCATION: string read FIMAGE_CARD_DEFAULT_LOCATION write FIMAGE_CARD_DEFAULT_LOCATION;
      property STACK_TYPE: TStackType read FSTACK_TYPE write FSTACK_TYPE;
      constructor Create(AOwner: TComponent); override;
  end;

implementation

uses
  Controller.Stacks, View.Principal, View.Congratulations, Model.Movement, Controller.Movement;

{ TModelCard }

constructor TModelCard.Create(AOwner: TComponent);
begin
  inherited;
  Self.OnDragOver:= OnDragOverCard;
  Self.OnDragDrop:= OnDragDropCard;
end;

procedure TModelCard.OnDragDropCard(Sender: TObject; const Data: TDragObject;
  const Point: TPointF);
var
  LCardReceive, LCardMove, aux: TModelCard;
  LMoved, LPreviousCardVisible: Boolean;
begin
  LPreviousCardVisible:= False;
  if (TModelCard(Data.Source).FVISIBLE) then
  begin
    LCardReceive:= TModelCard(Sender);
    LCardMove:= TModelCard(Data.Source);
    LMoved:= False;

    {***possibles moves***
      1-stack for stack
      2-stack for assembly
      3-stock for discard
      4-discard for stack
      5-discard for assembly
      6-assembly for stack
    }

    {1-stack for stack}
    if (LCardMove.STACK_TYPE in [tstStack1, tstStack2, tstStack3, tstStack4, tstStack5, tstStack6, tstStack7]) and
       (LCardReceive.STACK_TYPE in [tstStack1, tstStack2, tstStack3, tstStack4, tstStack5, tstStack6, tstStack7]) then
    begin
      if MoveStackForStack(LCardMove, LCardReceive) then
      begin
        LMoved:= True;
        LPreviousCardVisible:= LCardMove.FPREVIOUS_CARD.FVISIBLE;
        if (LCardMove.FPREVIOUS_CARD.FVALUE <> 0) then
        begin
          LCardMove.FPREVIOUS_CARD.Bitmap.LoadFromFile(LCardMove.FPREVIOUS_CARD.FIMAGE_CARD_LOCATION);
          LCardMove.FPREVIOUS_CARD.FVISIBLE:= True;
        end;
      end;
    end
    else {2-stack for assembly}
    if (LCardMove.STACK_TYPE in [tstStack1, tstStack2, tstStack3, tstStack4, tstStack5, tstStack6, tstStack7]) and
       (LCardReceive.STACK_TYPE in [tstAssemblyHeart, tstAssemblyDiamond, tstAssemblyClub, tstAssemblySpade]) then
    begin
      if MoveStackForAssembly(LCardMove, LCardReceive) then
      begin
        LMoved:= True;
        if (LCardMove.FPREVIOUS_CARD.FVALUE <> 0) then
        begin
          LCardMove.FPREVIOUS_CARD.Bitmap.LoadFromFile(LCardMove.FPREVIOUS_CARD.FIMAGE_CARD_LOCATION);
          LPreviousCardVisible:= LCardMove.FPREVIOUS_CARD.FVISIBLE;
          LCardMove.FPREVIOUS_CARD.FVISIBLE:= True;
        end;
      end;
    end
    else {3-stock for discard}
    if (LCardMove.STACK_TYPE = tstStock) and (LCardReceive.STACK_TYPE = tstDiscard) then
    begin
      if MoveStockForDiscard(LCardMove, LCardReceive) then
      begin
        LMoved:= True;
        LPreviousCardVisible:= True;
      end;
    end
    else {4-discard for stack}
    if (LCardMove.STACK_TYPE = tstDiscard) and
       (LCardReceive.STACK_TYPE in [tstStack1, tstStack2, tstStack3, tstStack4, tstStack5, tstStack6, tstStack7]) then
    begin
      if DiscardForStack(LCardMove, LCardReceive) then
      begin
        LMoved:= True;
        LPreviousCardVisible:= True;
      end;
    end
    else {5-discard for assembly}
    if (LCardMove.STACK_TYPE = tstDiscard) and (LCardReceive.STACK_TYPE in [tstAssemblyHeart, tstAssemblyDiamond, tstAssemblyClub, tstAssemblySpade]) then
    begin
      if DiscardForAssembly(LCardMove, LCardReceive) then
      begin
        LMoved:= True;
        LPreviousCardVisible:= True;
      end;
    end
    else {6-assembly for stack}
    if (LCardMove.STACK_TYPE in [tstAssemblyHeart, tstAssemblyDiamond, tstAssemblyClub, tstAssemblySpade]) and
       (LCardReceive.STACK_TYPE in [tstStack1, tstStack2, tstStack3, tstStack4, tstStack5, tstStack6, tstStack7]) then
    begin
      if MoveStackForStack(LCardMove, LCardReceive) then
      begin
        LMoved:= True;
        LPreviousCardVisible:= LCardMove.FPREVIOUS_CARD.FVISIBLE;
        if (LCardMove.FPREVIOUS_CARD.FVALUE <> 0) then
        begin
          LCardMove.FPREVIOUS_CARD.Bitmap.LoadFromFile(LCardMove.FPREVIOUS_CARD.FIMAGE_CARD_LOCATION);
          LCardMove.FPREVIOUS_CARD.FVISIBLE:= True;
        end;
      end;
    end;

    if LMoved then
    begin
      RegisterNewMovement(LPreviousCardVisible, LCardMove, LCardReceive);

      //prepare the previous and next
      LCardMove.FPREVIOUS_CARD.NEXT_CARD:= nil;
      LCardMove.FPREVIOUS_CARD:= nil;
      LCardReceive.NEXT_CARD:= LCardMove;
      LCardMove.FPREVIOUS_CARD:= LCardReceive;

      if (LCardReceive.STACK_TYPE in [tstAssemblyHeart, tstAssemblyDiamond, tstAssemblyClub, tstAssemblySpade]) then
      begin
        if TControllerStacks.FinishedGame then
        begin
          var LViewCongratulations: TViewCongratulations;
          LViewCongratulations:= TViewCongratulations.Create(ViewPrincipal);
          LViewCongratulations.CalculatedTimeEndGame;
          LViewCongratulations.Parent:= ViewPrincipal;
          LViewCongratulations.BringToFront;
          LViewCongratulations.lytContents.Visible:= False;
          LViewCongratulations.Animation.Enabled:= True;
        end;
      end;

      //ajustar o stack_type das cartas que estão juntas da carta que o usuário está movendo;
      aux:= LCardMove;
      while (aux <> nil) do
      begin
        aux.STACK_TYPE:= LCardReceive.STACK_TYPE;
        aux:= aux.NEXT_CARD;
      end;
    end;
  end;
end;

function TModelCard.MoveStackForStack(ACardMove, ACardReceive: TModelCard): Boolean;
begin
  Result:= False;
  if (ACardReceive.FVALUE = 0) and (ACardMove.FVALUE = 13) and (ACardReceive.FSUIT_CARD = tscNone) then
  begin
    ACardReceive.AddObject(ACardMove);
    Result:= True;
  end
  else if (ACardReceive.FCOLOR <> ACardMove.FCOLOR) and ((ACardReceive.FVALUE - 1) = ACardMove.FVALUE) and (ACardReceive.FNEXT_CARD = nil) then
  begin
    ACardReceive.AddObject(ACardMove);
    Result:= True;
  end;
end;

function TModelCard.MoveStackForAssembly(ACardMove, ACardReceive: TModelCard): Boolean;
begin
  Result:= False;
  if (ACardReceive.FSUIT_CARD = ACardMove.FSUIT_CARD) and ((ACardReceive.FVALUE + 1) = ACardMove.FVALUE) and (ACardReceive.FNEXT_CARD = nil) then
  begin
    ACardMove.Padding.Top:= 0;
    ACardReceive.AddObject(ACardMove);
    Result:= True;
  end;
end;

function TModelCard.MoveStockForDiscard(ACardMove, ACardReceive: TModelCard): Boolean;
begin
  ACardMove.Padding.Top:= 0;
  ACardReceive.AddObject(ACardMove);
  ACardMove.VISIBLE:= True;
  ACardMove.Bitmap.LoadFromFile(ACardMove.FIMAGE_CARD_LOCATION);
  Result:= True;
end;

function TModelCard.DiscardForStack(ACardMove, ACardReceive: TModelCard): Boolean;
begin
  Result:= False;
  if (ACardReceive.FVALUE = 0) and (ACardMove.FVALUE = 13) and (ACardReceive.FSUIT_CARD = tscNone) then
    Result:= True
  else if (ACardReceive.FCOLOR <> ACardMove.FCOLOR) and ((ACardReceive.FVALUE - 1) = ACardMove.FVALUE) and (ACardReceive.FNEXT_CARD = nil) then
    Result:= True;

  if Result then
  begin
    ACardMove.Padding.Top:= 23;
    ACardReceive.AddObject(ACardMove);
  end;
end;

function TModelCard.DiscardForAssembly(ACardMove, ACardReceive: TModelCard): Boolean;
begin
  Result:= False;
  if (ACardReceive.FSUIT_CARD = ACardMove.FSUIT_CARD) and ((ACardReceive.FVALUE + 1) = ACardMove.FVALUE) and (ACardReceive.FNEXT_CARD = nil) then
  begin
    ACardMove.Padding.Top:= 0;
    ACardReceive.AddObject(ACardMove);
    Result:= True;
  end;
end;

procedure TModelCard.RegisterNewMovement(APreviousCardVisible: Boolean; ACardMove, ACardReceive: TModelCard);
var
  LMovement: TModelMovement;
begin
  LMovement:= TModelMovement.Create;
  LMovement.PREVIOUS_MOVEMENT:= TControllerMovement.GetInstance.Items[Pred(TControllerMovement.GetInstance.Count)];
  LMovement.HEAD_STACK_MOVEMENT:= False;
  LMovement.NEXT_MOVIMENT:= nil;
  LMovement.PREVIOUS_CARD_VISIBLE:= APreviousCardVisible;
  LMovement.CARD:= ACardMove;
  LMovement.PREVIOUS_CARD:= ACardMove.PREVIOUS_CARD;
  LMovement.SPECIAL_MOVEMENT:= False;
  LMovement.ORIGIN_STACK_TYPE:= ACardMove.STACK_TYPE;
  LMovement.DESTINY_STACK_TYPE:= ACardReceive.STACK_TYPE;
  TControllerMovement.SetMovement(LMovement);
  TControllerMovement.SetLastCardMoved(ACardMove);
end;

procedure TModelCard.OnDragOverCard(Sender: TObject; const Data: TDragObject;
  const Point: TPointF; var Operation: TDragOperation);
begin
  if Self.FVISIBLE then
    Operation:=TDragOperation.Move;
end;
end.
