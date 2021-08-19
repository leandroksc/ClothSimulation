unit uCloth;

interface

uses
  Generics.Collections, Windows, Controls, Math, SysUtils, Graphics, Forms;

type
  TMouseRec = record
    down : Boolean;
		button: Integer;
		x: Integer;
		y: Integer;
		px: Integer;
		py: Integer;
  end;

  TConstraint = class;
  TCloth = class;

  TPonto = class
  private
    FListaConstraints : TList<TConstraint>;
    procedure add_force(x, y: Double);
    procedure pin(pinx, piny: Double);
    function GetConstraint(index: Integer): TConstraint;
  public
    x : Double;
    y : Double;
    px : Double;
    py : Double;
    vx : Double;
    vy : Double;
    pin_x : Double;
    pin_y : Double;
    constructor Create(x, y : Double);
    procedure update(delta: Double);
    procedure Draw;
    procedure resolve_constraints;
    procedure attach(APonto: TPonto);
    procedure remove_constraint(lnk: TConstraint);
    property Constraints[index : Integer] : TConstraint read GetConstraint;
  end;

  TConstraint = class
  public
    p1 : TPonto;
    p2 : TPonto;
    length : Integer;
    constructor Create(p1, p2: TPonto);
    procedure resolve;
    procedure draw;
  end;

  TCloth = class
  private
    FPoints : TList<TPonto>;
  public
    constructor Create;
    procedure update;
    procedure draw;
  end;

procedure update;

var
  AMouse : TMouseRec;
  cloth : TCloth;
	boundsx, boundsy : Integer;
  ABmp : TBitmap;
  ACanvasReal : TCanvas;

const
  physics_accuracy = 5;
  mouse_influence  = 20;
  mouse_cut        = 5;
  gravity          = 1200;
  cloth_height     = 30;
  cloth_width      = 50;
  start_y          = 20;
  spacing          = 7;
  tear_distance    = 60;

implementation

constructor TPonto.Create(x, y: Double);
begin
	Self.x := x;
	Self.y := y;
	Self.px := x;
	Self.py := y;
	Self.vx := 0;
	Self.vy := 0;
	Self.pin_x := -1;
	Self.pin_y := -1;
	FListaConstraints := TList<TConstraint>.Create;;
end;

procedure TPonto.update(delta: Double);
var
  diff_x, diff_y, dist, nx, ny : Double;
begin
 	if AMouse.down then
  begin
		diff_x := Self.x - AMouse.X;
		diff_y := Self.y - AMouse.Y;
		dist   := Sqrt(diff_x * diff_x + diff_y * diff_y);

		if AMouse.button = 0 then
    begin
			if(dist < mouse_influence) then
      begin
				Self.px := Self.x - (AMouse.x - AMouse.px) * 1.8;
				Self.py := Self.y - (AMouse.y - AMouse.py) * 1.8;
			end;
		end
    else if (dist < mouse_cut) then
      FListaConstraints.DeleteRange(0, FListaConstraints.Count);
	end;

	Self.add_force(0, gravity);

	delta := delta * delta;
	nx := Self.x + ((Self.x - Self.px) * 0.99) + ((Self.vx / 2) * delta);
	ny := Self.y + ((Self.y - Self.py) * 0.99) + ((Self.vy / 2) * delta);

	Self.px := Self.x;
	Self.py := Self.y;

	Self.x := nx;
	Self.y := ny;

	Self.vy := 0;
  Self.vx := 0;
end;

procedure TPonto.Draw;
var
  i : Integer;
begin
 	if (FListaConstraints.Count <= 0) then
    Exit;

	for i := FListaConstraints.Count - 1 downto 0 do
    Constraints[i].draw;
end;

function TPonto.GetConstraint(index: Integer): TConstraint;
begin
  Result := FListaConstraints[index];
end;

procedure TPonto.resolve_constraints;
var
  i : Integer;
begin
	if (Self.pin_x <> -1) and (Self.pin_y <> -1) then
  begin
		Self.x := Self.pin_x;
		Self.y := Self.pin_y;
		Exit;
	end;

	for I := FListaConstraints.Count - 1 downto 0 do
    Constraints[i].resolve;

	if Self.x > boundsx then
    Self.x := 2 * boundsx - Self.x
  else if 1 > Self.x then
    Self.x := 2 - Self.x;

	if Self.y < 1 then
    Self.y := 2 - Self.y
  else if Self.y > boundsy then
    Self.y := 2 * boundsy - Self.y;
end;


procedure TPonto.attach(APonto: TPonto);
begin
	FListaConstraints.Add(TConstraint.Create(Self, APonto));
end;

procedure TPonto.remove_constraint(lnk: TConstraint);
var
  i : Integer;
begin
	for i := FListaConstraints.Count - 1 downto 0 do
  begin
    if (FListaConstraints[i] = lnk) then
      FListaConstraints.Delete(i);
  end;
end;

procedure TPonto.add_force(x, y : Double);
begin
	Self.vx := Self.vx + x;
	Self.vy := Self.vy + y;
end;

procedure TPonto.pin(pinx, piny: Double);
begin
	Self.pin_x := pinx;
	Self.pin_y := piny;
end;

constructor TConstraint.Create(p1, p2: TPonto);
begin
	Self.p1 := p1;
	Self.p2 := p2;
	Self.length := spacing;
end;

procedure TConstraint.resolve;
var
  diff_x, diff_y, dist, diff, px, py : Double;
begin
	diff_x := Self.p1.x - Self.p2.x;
	diff_y := Self.p1.y - Self.p2.y;
	dist   := Sqrt(diff_x * diff_x + diff_y * diff_y);
	diff   := (Self.length - dist) / dist;

	if (dist > tear_distance) then
    Self.p1.remove_constraint(Self);

	px := diff_x * diff * 0.5;
	py := diff_y * diff * 0.5;

	Self.p1.x := Self.p1.x + px;
	Self.p1.y := Self.p1.y + py;
	Self.p2.x := Self.p2.x - px;
	Self.p2.y := Self.p2.y - py;
end;

procedure TConstraint.draw;
begin
  ABmp.Canvas.Pen.Color := clBlack;
	ABmp.Canvas.moveTo(Trunc(Self.p1.x), Trunc(Self.p1.y));
	ABmp.Canvas.lineTo(Trunc(Self.p2.x), Trunc(Self.p2.y));
end;

constructor TCloth.Create;
var
  start_x : Double;
  y, x : Integer;
  p : TPonto;
begin
	FPoints := TList<TPonto>.Create;

//	start_x := (ACanvas.ClipRect.Left - ACanvas.ClipRect.Right) / 2 - cloth_width * spacing / 2;
  start_x := 20;
	for y := 0 to cloth_height do
  begin
		for x := 0 to cloth_width do
    begin

			p := TPonto.Create(start_x + x * spacing, start_y + y * spacing);

      if (x <> 0) then
        p.attach(Self.FPoints[Self.FPoints.Count - 1]);
			if y = 0 then
        p.pin(p.x, p.y);
			if y <> 0 then
        p.attach(Self.FPoints[x + (y - 1) * (cloth_width + 1)]);

			Self.FPoints.Add(p);
		end;
	end;
end;

procedure TCloth.update;
var
  i, p : Integer;
begin
	for i := physics_accuracy downto 0 do
  begin
		for p := FPoints.Count - 1 downto 0 do
      fpoints[p].resolve_constraints;
	end;
	for i := FPoints.Count - 1 downto 0 do
    fpoints[i].update(0.016);
end;

procedure TCloth.draw;
var
  i : Integer;
begin
//	ACanvas.beginPath();

	for i := cloth.fpoints.Count - 1 downto 0 do
    cloth.fpoints[i].draw;

//	ctx.stroke();
end;

procedure update;
begin

//	ctx.clearRect(0, 0, canvas.width, canvas.height);
  ABmp.Canvas.Brush.Color := clWhite;
  ABmp.Canvas.FillRect(ABmp.Canvas.ClipRect);

	cloth.update();
	cloth.draw();
  ACanvasReal.Draw(0, 0, ABmp);
//  Application.processmessages;

//	requestAnimFrame(update);
end;

end.
