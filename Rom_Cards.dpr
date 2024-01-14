program Rom_Cards;

uses
  System.StartUpCopy,
  FMX.Forms,
  View.Principal in 'src\view\View.Principal.pas' {ViewPrincipal},
  Model.Card in 'src\model\Model.Card.pas',
  Model.Stack in 'src\model\Model.Stack.pas',
  Controller.Cards in 'src\controller\Controller.Cards.pas',
  Controller.Stacks in 'src\controller\Controller.Stacks.pas',
  View.MenuPrincipal in 'src\view\View.MenuPrincipal.pas' {ViewMenuPrincipal},
  View.ExitGame in 'src\view\View.ExitGame.pas' {ViewExitGame: TFrame},
  View.AboutGame in 'src\view\View.AboutGame.pas' {ViewAboutGame: TFrame},
  View.Congratulations in 'src\view\View.Congratulations.pas' {ViewCongratulations: TFrame},
  View.Tip in 'src\view\View.Tip.pas' {ViewTip: TFrame},
  Provider.Loading in 'src\provider\Provider.Loading.pas',
  Provider.Functions in 'src\provider\Provider.Functions.pas',
  View.HowToPlay in 'src\view\View.HowToPlay.pas' {ViewHowToPlay: TFrame},
  View.Ranking in 'src\view\View.Ranking.pas' {ViewRanking: TFrame},
  View.PauseGame in 'src\view\View.PauseGame.pas' {ViewPauseGame: TFrame},
  View.HelperPenalty in 'src\view\View.HelperPenalty.pas' {ViewHelperPenalty: TFrame};

{$R *.res}

begin
  Application.Initialize;
  ReportMemoryLeaksOnShutdown:= True;
  Application.CreateForm(TViewMenuPrincipal, ViewMenuPrincipal);
  Application.Run;
end.
