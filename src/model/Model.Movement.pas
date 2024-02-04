unit Model.Movement;

interface

uses
  Model.Card;

type

  TMovement = class
    private
    FPREVIOUS_MOVEMENT: TMovement;
    FNEXT_MOVIMENT: TMovement;
    FPREVIOUS_CARD_VISIBLE: Boolean;
    FSPECIAL_MOVEMENT: Boolean;
    FPREVIOUS_CARD: TCard;
    FORIGIN_STACK_TYPE: TStackType;
    FDESTINY_STACK_TYPE: TStackType;
    FHEAD_STACK_MOVEMENT: Boolean;
    FCARD: TCard;
    public
      property PREVIOUS_MOVEMENT: TMovement read FPREVIOUS_MOVEMENT write FPREVIOUS_MOVEMENT;
      property NEXT_MOVIMENT: TMovement read FNEXT_MOVIMENT write FNEXT_MOVIMENT;
      property PREVIOUS_CARD_VISIBLE: Boolean read FPREVIOUS_CARD_VISIBLE write FPREVIOUS_CARD_VISIBLE;
      property SPECIAL_MOVEMENT: Boolean read FSPECIAL_MOVEMENT write FSPECIAL_MOVEMENT;
      property CARD: TCard read FCARD write FCARD;
      property PREVIOUS_CARD: TCard read FPREVIOUS_CARD write FPREVIOUS_CARD;
      property ORIGIN_STACK_TYPE: TStackType read FORIGIN_STACK_TYPE write FORIGIN_STACK_TYPE;
      property DESTINY_STACK_TYPE: TStackType read FDESTINY_STACK_TYPE write FDESTINY_STACK_TYPE;
      property HEAD_STACK_MOVEMENT: Boolean read FHEAD_STACK_MOVEMENT write FHEAD_STACK_MOVEMENT;
  end;

implementation

end.
