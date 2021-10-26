unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtDlgs, Vcl.ExtCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    OpenPictureDialog1: TOpenPictureDialog;
    OpenDialog1: TOpenDialog;
    Image1: TImage;
    ButtonedEdit1: TButtonedEdit;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ButtonedEdit1RightButtonClick(Sender: TObject);
  private
    { Private declarations }
    function LoadNetworkDataFromFile(): boolean;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses neuralnetwork, neuraldatasets, neuralvolume, neuralfit;
var NN: TNNet;
const NumClasses = 10;
      nnfilename = 'autosave.nn';
      datadirectory = '..\..\Data\cifar-10-batches-bin\';

{$R *.dfm}

function DesignCifar10NeuralNetwork(): TNNet;
begin
  RESULT := TNNet.Create();
  RESULT.AddLayer([
    TNNetInput.Create(32, 32, 3), //32x32x3 Input Image
    TNNetConvolutionReLU.Create({Features=}16, {FeatureSize=}5, {Padding=}0, {Stride=}1, {SuppressBias=}0),
    TNNetMaxPool.Create({Size=}2),
    TNNetConvolutionReLU.Create({Features=}32, {FeatureSize=}5, {Padding=}0, {Stride=}1, {SuppressBias=}0),
    TNNetMaxPool.Create({Size=}2),
    TNNetConvolutionReLU.Create({Features=}32, {FeatureSize=}5, {Padding=}0, {Stride=}1, {SuppressBias=}0),
    TNNetFullConnectReLU.Create({Neurons=}32),
    TNNetFullConnectLinear.Create(NumClasses),
    TNNetSoftMax.Create()
  ]);
end;

procedure TForm1.Button1Click(Sender: TObject);
var
    ImgTrainingVolumes, ImgValidationVolumes,
    ImgTestVolumes: TNNetVolumeList;
    NeuralFit: TNeuralImageFit;

const
      fLearningRate = 0.01;
      fInertia = 0.1;
      warningRetrainMsg = 'Are you really want to re-train the network?! This can takes a huge amount of time! Are you sure you know what you do?';
begin

  if NN <> nil then
    if MessageDlg(warningRetrainMsg, TMsgDlgType.mtWarning, mbYesNoCancel, 0) <> mrYes then
      exit;
  NN := DesignCifar10NeuralNetwork();

  CreateCifar10Volumes(ImgTrainingVolumes, ImgValidationVolumes, ImgTestVolumes);

  WriteLn('Neural Network will minimize error with:');
  WriteLn(' Layers: ', NN.CountLayers());
  WriteLn(' Neurons:', NN.CountNeurons());
  WriteLn(' Weights:', NN.CountWeights());

  NeuralFit := TNeuralImageFit.Create;
  NeuralFit.InitialLearningRate := fLearningRate;
  NeuralFit.Inertia := fInertia;
  NeuralFit.Fit(NN, ImgTrainingVolumes, ImgValidationVolumes, ImgTestVolumes, NumClasses, {batchsize}128, {epochs}5);

end;

procedure TForm1.Button2Click(Sender: TObject);
var
    Img: TTinyImage;
    cifarFile: TTInyImageFile;
    ImgVolume, ClassVolume: TNNetVolume;

    i: Integer;
    maxConfidence: double;
    indexConfidence: Integer;
    filename: String;
const
      fLearningRate = 0.01;
      fInertia = 0.1;

begin
  if NN = nil then
  begin
    NN := DesignCifar10NeuralNetwork();

    if LoadNetworkDataFromFile() then
      ShowMessage('Network data is successfully loaded from ' + OpenDialog1.FileName)
    else
      exit;
  end;

  OpenPictureDialog1.Filter := 'Bitmap 32x32 (*.bmp)|*.bmp';
  OpenPictureDialog1.FilterIndex := 0;
  if OpenPictureDialog1.Execute then
  begin
    filename := OpenPictureDialog1.FileName;
    Image1.Picture.LoadFromFile(filename);
  end
  else    //filename := 'ship0001 (1).bmp';
    exit;

  AssignFile(cifarFile, fileName);
  Reset(cifarFile);

  Read(cifarFile, Img);
  ImgVolume := TNNetVolume.Create;
  LoadTinyImageIntoNNetVolume(Img, ImgVolume);

  ImgVolume.RgbImgToNeuronalInput(csEncodeRGB);
  CloseFile(cifarFile);
  WriteLn(String.Format('Image from %s is loaded', [filename] ));

  NN.Compute(ImgVolume);

  ClassVolume := TNNetVolume.Create(NumClasses);
  NN.GetOutput(ClassVolume);

  maxConfidence := 0;
  indexConfidence := NumClasses;
  for i := 0 to NumClasses - 1 do
  begin
    Writeln(String.Format('Confidence of "%s" = %5.2f %%', [csTinyImageLabel[i], ClassVolume.FData[i]*100]));
    if ClassVolume.FData[i] > maxConfidence then
    begin
      maxConfidence := ClassVolume.FData[i];
      indexConfidence := i;
    end;
  end;
  ShowMessage(String.Format('%s is recognized with %2.0f %% confidence',
              [csTinyImageLabel[indexConfidence], maxConfidence * 100]));
end;

procedure TForm1.ButtonedEdit1RightButtonClick(Sender: TObject);
begin
  if NN = nil then
    NN := DesignCifar10NeuralNetwork();

  OpenDialog1.FileName := ButtonedEdit1.Text;
  LoadNetworkDataFromFile();
end;

procedure TForm1.FormCreate(Sender: TObject);
var bitmap: TBitmap;
    imagesList : TImageList;
begin
  bitmap := TBitmap.Create();
  bitmap.LoadFromFile('..\..\iconOpenNeuralNetwork.bmp');
  imagesList := TImageList.Create(Self);
  imagesList.Add(bitmap, nil);
  ButtonedEdit1.Images := imagesList;
  ButtonedEdit1.RightButton.Visible := true;
	ButtonedEdit1.RightButton.Enabled := true;
  ButtonedEdit1.RightButton.Hint := 'Open file of neural network weights';
	ButtonedEdit1.RightButton.ImageIndex := 0;
	ButtonedEdit1.RightButton.DisabledImageIndex := 0;
	ButtonedEdit1.RightButton.PressedImageIndex := 0;
	ButtonedEdit1.RightButton.HotImageIndex := 0;
  ButtonedEdit1.Text := '';
end;



function TForm1.LoadNetworkDataFromFile: boolean;
begin
  if OpenDialog1.FileName = '' then
    OpenDialog1.FileName := nnfilename;

  if OpenDialog1.Execute() then
  begin
    Writeln('Trained network loading...');
    NN.LoadDataFromFile(OpenDialog1.FileName);

    Writeln('Number of layers:' + IntToStr(NN.CountLayers));
    Writeln('Number of neurons:' + IntToStr(NN.CountNeurons));

    ButtonedEdit1.Text := ExtractFileName(OpenDialog1.FileName);
    RESULT := True;
  end
  else
    RESULT := False;
end;

begin
  neuraldatasets.directory := datadirectory;
end.
