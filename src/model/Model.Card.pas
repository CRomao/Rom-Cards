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

  TCard = class(TImage)
    private
    FVALUE: Integer;
    FSUIT_CARD: TSuitCard;
    FVISIBLE: Boolean;
    FCOLOR: TColorCard;
    FPREVIOUS_CARD: TCard;
    FNEXT_CARD: TCard;
    FIMAGE_CARD_LOCATION: string;
    FIMAGE_CARD_DEFAULT_LOCATION: string;
    FSTACK_ID: Integer;

  protected
    procedure OnDragOverCard(Sender: TObject; const Data: TDragObject;
    const Point: TPointF; var Operation: TDragOperation);
    procedure OnDragDropCard(Sender: TObject; const Data: TDragObject; const Point: TPointF);

    public
      property VALUE: Integer read FVALUE write FVALUE;
      property SUIT_CARD: TSuitCard read FSUIT_CARD write FSUIT_CARD;
      property VISIBLE: Boolean read FVISIBLE write FVISIBLE;
      property COLOR: TColorCard read FCOLOR write FCOLOR;
      property PREVIOUS_CARD: TCard read FPREVIOUS_CARD write FPREVIOUS_CARD;
      property NEXT_CARD: TCard read FNEXT_CARD write FNEXT_CARD;
      property IMAGE_CARD_LOCATION: string read FIMAGE_CARD_LOCATION write FIMAGE_CARD_LOCATION;
      property IMAGE_CARD_DEFAULT_LOCATION: string read FIMAGE_CARD_DEFAULT_LOCATION write FIMAGE_CARD_DEFAULT_LOCATION;
      property STACK_ID: Integer read FSTACK_ID write FSTACK_ID;
      constructor Create(AOwner: TComponent); override;
  end;

  TMovement = class
    private
    FPREVIOUS_MOVEMENT: TMovement;
    FNEXT_MOVIMENT: TMovement;
    FPREVIOUS_CARD_VISIBLE: Boolean;
    FSPECIAL_MOVEMENT: Boolean;
    FPREVIOUS_CARD: TCard;
    FORIGIN_STACK_ID: Integer;
    FDESTINY_STACK_ID: Integer;
    FPOINTS_MOVEMENT: Integer;
    FHEAD_STACK_MOVEMENT: Boolean;
    FCARD: TCard;
    public
      property PREVIOUS_MOVEMENT: TMovement read FPREVIOUS_MOVEMENT write FPREVIOUS_MOVEMENT;
      property NEXT_MOVIMENT: TMovement read FNEXT_MOVIMENT write FNEXT_MOVIMENT;
      property PREVIOUS_CARD_VISIBLE: Boolean read FPREVIOUS_CARD_VISIBLE write FPREVIOUS_CARD_VISIBLE;
      property SPECIAL_MOVEMENT: Boolean read FSPECIAL_MOVEMENT write FSPECIAL_MOVEMENT;
      property CARD: TCard read FCARD write FCARD;
      property PREVIOUS_CARD: TCard read FPREVIOUS_CARD write FPREVIOUS_CARD;
      property ORIGIN_STACK_ID: Integer read FORIGIN_STACK_ID write FORIGIN_STACK_ID;
      property DESTINY_STACK_ID: Integer read FDESTINY_STACK_ID write FDESTINY_STACK_ID;
      property POINTS_MOVEMENT: Integer read FPOINTS_MOVEMENT write FPOINTS_MOVEMENT;
      property HEAD_STACK_MOVEMENT: Boolean read FHEAD_STACK_MOVEMENT write FHEAD_STACK_MOVEMENT;

  end;

  TControllerMovement = class
    private
      class var FListMovement: TList<TMovement>;
      class var FLastCardMoved: Tcard;
    public
      class function GeListMovement: TList<TMovement>;
      class procedure SetMovement(AMovement: TMovement);
      class procedure CleanMemory;
      class procedure SetLastCardMoved(ACard: TCard);
      class function GetLastCardMoved: TCard;
      class function GetLastMovement: TMovement;
  end;

implementation

uses
  Controller.Stacks, View.Principal, View.Congratulations;

{ TCard }

constructor TCard.Create(AOwner: TComponent);
begin
  inherited;
  Self.OnDragOver:= OnDragOverCard;
  Self.OnDragDrop:= OnDragDropCard;
end;

procedure TCard.OnDragDropCard(Sender: TObject; const Data: TDragObject;
  const Point: TPointF);
var
  S, D, aux: TCard;
  LMoved, LPreviousCardVisible: Boolean;
  LMovement: TMovement;
begin
  LPreviousCardVisible:= False;
  if (TCard(Data.Source).FVISIBLE) then
  begin
    S:= TCard(Sender);
    D:= TCard(Data.Source);
    LMoved:= False;

    {***possibles moves***
    1-stack for stack
    2-stack for assembly
    3-stock for discard
    4-discard for stack
    5-discard for assembly
    6-assembly for stack -> sofre penalidade
    }

    {1-stack for stack}
    if (D.STACK_ID in [0,1,2,3,4,5,6]) and (S.STACK_ID in [0,1,2,3,4,5,6]) then
    begin
      if (S.FVALUE = 0) and (D.FVALUE = 13) and (S.FSUIT_CARD = tscNone) then
      begin
        S.AddObject(D);
        LMoved:= True;
      end
      else if (S.FCOLOR <> D.FCOLOR) and ((S.FVALUE - 1) = D.FVALUE) and (S.FNEXT_CARD = nil) then
      begin
        S.AddObject(D);
        LMoved:= True;
      end;

      if LMoved then
      begin
        LPreviousCardVisible:= D.FPREVIOUS_CARD.FVISIBLE;
        if (D.FPREVIOUS_CARD.FVALUE <> 0) then
        begin
          D.FPREVIOUS_CARD.Bitmap.LoadFromFile(D.FPREVIOUS_CARD.FIMAGE_CARD_LOCATION);
          D.FPREVIOUS_CARD.FVISIBLE:= True;
        end;
      end;
    end;

    {2-stack for assembly}
    if (D.STACK_ID in [0,1,2,3,4,5,6]) and (S.STACK_ID in [9,10,11,12]) then
    begin
      if (S.FSUIT_CARD = D.FSUIT_CARD) and ((S.FVALUE + 1) = D.FVALUE) and (S.FNEXT_CARD = nil) then
      begin
        D.Padding.Top:= 0;
        S.AddObject(D);
        LMoved:= True;
      end;

      if LMoved then
      begin
        if (D.FPREVIOUS_CARD.FVALUE <> 0) then
        begin
          D.FPREVIOUS_CARD.Bitmap.LoadFromFile(D.FPREVIOUS_CARD.FIMAGE_CARD_LOCATION);
          LPreviousCardVisible:= D.FPREVIOUS_CARD.FVISIBLE;
          D.FPREVIOUS_CARD.FVISIBLE:= True;
        end;
      end;
    end;

    {3-stock for discard}
    if (D.STACK_ID = 7) and (S.STACK_ID = 8) then
    begin
      D.Padding.Top:= 0;
      S.AddObject(D);
      LMoved:= True;
      LPreviousCardVisible:= True;
      D.VISIBLE:= True;
      D.Bitmap.LoadFromFile(D.FIMAGE_CARD_LOCATION);
    end;

    {4-discard for stack}
    if (D.STACK_ID = 8) and (S.STACK_ID in [0,1,2,3,4,5,6]) then
    begin
      if (S.FVALUE = 0) and (D.FVALUE = 13) and (S.FSUIT_CARD = tscNone) then
      begin
        D.Padding.Top:= 23;
        S.AddObject(D);
        LMoved:= True;
        LPreviousCardVisible:= True;
      end
      else if (S.FCOLOR <> D.FCOLOR) and ((S.FVALUE - 1) = D.FVALUE) and (S.FNEXT_CARD = nil) then
      begin
        D.Padding.Top:= 23;
        S.AddObject(D);
        LMoved:= True;
        LPreviousCardVisible:= True;
      end;
    end;

    {5-discard for assembly}
    if (D.STACK_ID = 8) and (S.STACK_ID in [9,10,11,12]) then
    begin
      if (S.FSUIT_CARD = D.FSUIT_CARD) and ((S.FVALUE + 1) = D.FVALUE) and (S.FNEXT_CARD = nil) then
      begin
        D.Padding.Top:= 0;
        S.AddObject(D);
        LMoved:= True;
        LPreviousCardVisible:= True;
      end;
    end;

    {6-assembly for stack}
    if (D.STACK_ID in [9, 10, 11, 12]) and (S.STACK_ID in [0,1,2,3,4,5,6]) then
    begin
      if (S.FVALUE = 0) and (D.FVALUE = 13) and (S.FSUIT_CARD = tscNone) then
      begin
        S.AddObject(D);
        LMoved:= True;
      end
      else if (S.FCOLOR <> D.FCOLOR) and ((S.FVALUE - 1) = D.FVALUE) and (S.FNEXT_CARD = nil) then
      begin
        D.Padding.Top:= 23;
        S.AddObject(D);
        LMoved:= True;
      end;

      if LMoved then
      begin
        LPreviousCardVisible:= D.FPREVIOUS_CARD.FVISIBLE;
        if (D.FPREVIOUS_CARD.FVALUE <> 0) then
        begin
          D.FPREVIOUS_CARD.Bitmap.LoadFromFile(D.FPREVIOUS_CARD.FIMAGE_CARD_LOCATION);
          D.FPREVIOUS_CARD.FVISIBLE:= True;
        end;
      end;
    end;


    //prepare the previous and next
    if LMoved then
    begin
      {Register the current movement}
      LMovement:= TMovement.Create;
      LMovement.PREVIOUS_MOVEMENT:= TControllerMovement.GeListMovement.Items[Pred(TControllerMovement.GeListMovement.Count)];
      LMovement.HEAD_STACK_MOVEMENT:= False;
      LMovement.NEXT_MOVIMENT:= nil;
      LMovement.PREVIOUS_CARD_VISIBLE:= LPreviousCardVisible;
      LMovement.CARD:= D;
      LMovement.PREVIOUS_CARD:= D.PREVIOUS_CARD;
      LMovement.SPECIAL_MOVEMENT:= False;
      LMovement.ORIGIN_STACK_ID:= D.STACK_ID;
      LMovement.DESTINY_STACK_ID:= S.STACK_ID;
      LMovement.POINTS_MOVEMENT:= 0;

      TControllerMovement.SetMovement(LMovement);
      TControllerMovement.SetLastCardMoved(D);

      D.FPREVIOUS_CARD.NEXT_CARD:= nil;
      D.FPREVIOUS_CARD:= nil;

      S.NEXT_CARD:= D;
      D.FPREVIOUS_CARD:= S;

      if (S.STACK_ID in [9, 10, 11,12]) then
      begin
       if TControllerStacks.FinishedGame then
       begin
          var LViewCongratulations: TViewCongratulations;

          LViewCongratulations:= TViewCongratulations.Create(ViewPrincipal);

          LViewCongratulations.Parent:= ViewPrincipal;
          LViewCongratulations.BringToFront;
          LViewCongratulations.lblTitle.Visible:= False;
          LViewCongratulations.rtgNo.Visible:= False;
          LViewCongratulations.rtgYes.Visible:= False;
          LViewCongratulations.lblNickname.Visible:= False;
          LViewCongratulations.lblInformation.Visible:= False;
          LViewCongratulations.edtNickName.Visible:= False;
          LViewCongratulations.Animation.Enabled:= True;
        end;
      end;

      aux:= D;
      //ajustar o id da pilha das cartas acima da carta que acabou de ser movida;
      while (aux <> nil) do
      begin
        aux.STACK_ID:= S.STACK_ID;
        aux:= aux.NEXT_CARD;
      end;

    end;
  end;
end;

procedure TCard.OnDragOverCard(Sender: TObject; const Data: TDragObject;
  const Point: TPointF; var Operation: TDragOperation);
begin
  if Self.FVISIBLE then
    Operation:=TDragOperation.Move;
end;

{ TControllerMovement }

class procedure TControllerMovement.CleanMemory;
var
  I: integer;
begin
  for I := 0 to Pred(GeListMovement.Count) do
    GeListMovement.Items[I].Free;

  GeListMovement.Free;
  FListMovement:= nil;
end;

class function TControllerMovement.GeListMovement: TList<TMovement>;
var
  LMovement: TMovement;
begin
  if (FListMovement = nil) then
  begin
    FListMovement:= TList<TMovement>.Create;
    LMovement:= TMovement.Create;
    LMovement.NEXT_MOVIMENT:= nil;
    LMovement.PREVIOUS_MOVEMENT:= nil;
    LMovement.CARD:= nil;
    LMovement.PREVIOUS_CARD:= nil;
    LMovement.HEAD_STACK_MOVEMENT:= True;
    FListMovement.Add(LMovement);
  end;

  Result:= FListMovement;
end;

class function TControllerMovement.GetLastCardMoved: TCard;
begin
  Result:= FLastCardMoved;
end;

class function TControllerMovement.GetLastMovement: TMovement;
begin
  Result:= GeListMovement.Last;
end;

class procedure TControllerMovement.SetLastCardMoved(ACard: TCard);
begin
  FLastCardMoved:= ACard;
end;

class procedure TControllerMovement.SetMovement(AMovement: TMovement);
begin
  FListMovement.Add(AMovement);
end;


end.
