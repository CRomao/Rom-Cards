unit Controller.Movement;

interface

uses
Model.Movement, Model.Card, System.Generics.Collections;

type

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
