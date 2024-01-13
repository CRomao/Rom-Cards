unit View.Congratulations;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Ani, FMX.Objects, FMX.Controls.Presentation, FMX.Layouts, FMX.Edit,
  REST.Types, REST.Client, Data.Bind.Components, Data.Bind.ObjectScope, System.JSON;

type
  TViewCongratulations = class(TFrame)
    lytContainer: TLayout;
    rtgContainer: TRectangle;
    lytOptions: TLayout;
    rtgOptions: TRectangle;
    lblTitle: TLabel;
    Layout1: TLayout;
    rtgTopClose: TRectangle;
    Rectangle9: TRectangle;
    rtgClose: TRectangle;
    imgClose: TImage;
    Animation: TFloatAnimation;
    lblInformation: TLabel;
    edtNickName: TEdit;
    lblNickname: TLabel;
    rtgNo: TRectangle;
    lblNo: TLabel;
    rtgYes: TRectangle;
    lblYes: TLabel;
    RESTClient: TRESTClient;
    Req: TRESTRequest;
    Res: TRESTResponse;
    procedure rtgNoClick(Sender: TObject);
    procedure AnimationFinish(Sender: TObject);
    procedure rtgYesClick(Sender: TObject);
    procedure imgCloseClick(Sender: TObject);
  private
    { Private declarations }
    FCloseAnimation, FCloseAnimationGame: Boolean;
    procedure SaveRankingPlayer;
  public
    { Public declarations }
  end;

implementation

uses
  View.Principal;

{$R *.fmx}

procedure TViewCongratulations.AnimationFinish(Sender: TObject);
begin
  if FCloseAnimation then
  begin
    if Assigned(ViewPrincipal) then
      ViewPrincipal.Close;
  end
  else
  if FCloseAnimationGame then
  begin
    if Assigned(ViewPrincipal) then  //colocar para salvar o rank
      ViewPrincipal.Close;
  end
  else
  begin
    ViewPrincipal.FPausedGame:= True;
    ViewPrincipal.FEndGame:= True;
    lblTitle.Visible:= True;
    rtgNo.Visible:= True;
    rtgYes.Visible:= True;
    lblNickname.Visible:= True;
    lblInformation.Visible:= True;
    edtNickName.Visible:= True;
  end;
end;

procedure TViewCongratulations.imgCloseClick(Sender: TObject);
begin
  Animation.Enabled:= False;
  FCloseAnimation:= True;
  lblTitle.Visible:= False;
  lblNickname.Visible:= False;
  lblInformation.Visible:= False;
  edtNickName.Visible:= False;
  Animation.Inverse:= True;
  Animation.Enabled:= True;
end;

procedure TViewCongratulations.rtgNoClick(Sender: TObject);
begin
  Animation.Enabled:= False;
  FCloseAnimation:= True;
  lblTitle.Visible:= False;
  lblNickname.Visible:= False;
  lblInformation.Visible:= False;
  edtNickName.Visible:= False;
  rtgNo.Visible:= False;
  rtgYes.Visible:= False;
  Animation.Inverse:= True;
  Animation.Enabled:= True;
end;

procedure TViewCongratulations.rtgYesClick(Sender: TObject);
begin
  if (edtNickName.Text = EmptyStr) then
    Abort;

  SaveRankingPlayer;
  Animation.Enabled:= False;
  FCloseAnimationGame:= True;
  lblTitle.Visible:= False;
  lblNickname.Visible:= False;
  lblInformation.Visible:= False;
  edtNickName.Visible:= False;
  rtgNo.Visible:= False;
  rtgYes.Visible:= False;
  Animation.Inverse:= True;
  Animation.Enabled:= True;
end;

procedure TViewCongratulations.SaveRankingPlayer;
var
  LPlayer: TJSONObject;
begin
  Req.Body.ClearBody;

  LPlayer:= TJSONObject.Create.
                  AddPair('nick_name', edtNickName.Text).
                  AddPair('time_played', ViewPrincipal.FTempoCronometroText);

  Req.Body.Add((LPlayer.ToString),ContentTypeFromString('application/json'));
  Req.Execute;

  if (Req.Response.StatusCode <> 200) and (Req.Response.StatusCode <> 201) then
    ShowMessage('Erro ao enviar para o ranking')
  else
  begin
    ShowMessage('Enviado para o ranking!');
  end;

  LPlayer.Free;
end;

end.
