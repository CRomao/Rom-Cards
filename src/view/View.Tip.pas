unit View.Tip;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Ani, FMX.Edit, FMX.Objects, FMX.Controls.Presentation, FMX.Layouts,
  system.Generics.Collections;

type
  TViewTip = class(TFrame)
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
    lytCards: TLayout;
    imgCardMove: TImage;
    Image2: TImage;
    lblTitle: TLabel;
    rtgStack2: TRectangle;
    imgCardReceive: TImage;
    procedure AnimationFinish(Sender: TObject);
    procedure imgCloseClick(Sender: TObject);
  private
    { Private declarations }
    FCloseAnimation: Boolean;
  public
    { Public declarations }
    procedure SetImageCards(AImages: TList<string>);
  end;

implementation

{$R *.fmx}

procedure TViewTip.AnimationFinish(Sender: TObject);
begin
  if FCloseAnimation then
  begin

    Self.Free;
  end
  else
  begin
    lblTitle.Visible:= True;
    lytCards.Visible:= True;
  end;
end;

procedure TViewTip.imgCloseClick(Sender: TObject);
begin
  Animation.Enabled:= False;
  FCloseAnimation:= True;
  lblTitle.Visible:= False;
  lytCards.Visible:= False;
  Animation.Inverse:= True;
  Animation.Enabled:= True;
end;

procedure TViewTip.SetImageCards(AImages: TList<string>);
begin
  if (AImages.Count = 2) then
  begin
    imgCardMove.Bitmap.LoadFromFile(AImages.Items[0]);
    imgCardReceive.Bitmap.LoadFromFile(AImages.Items[1]);
  end
  else
  if (AImages.Count = 1) then
    imgCardMove.Bitmap.LoadFromFile(AImages.Items[0]);

  AImages.Free;
end;

end.
