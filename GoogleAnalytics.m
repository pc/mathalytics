(* ::Package:: *)

(* ::Title:: *)
(*GoogleAnalytics*)


(* ::Author:: *)
(*Patrick Collison*)
(*patrick@collison.ie*)


BeginPackage["GoogleAnalytics`"];

Begin["`Private`"];

GAInitialize[] := Module[{},
	Install["/Users/patrick/Downloads/pythonika-1.0/Pythonika"];
	Py["\<
import sys
sys.path.append('/Users/patrick/Dropbox/Projects/Mathalytics/')
from mathalytics import *
\>"]];

GALogin[user_, pass_] := Module[{},
	ToPy["_user", user];
	ToPy["_pass", pass];
	Py["m.connect(_user, _pass)"]];

GAAccounts[] := Py["m.accounts()"];

GAAccounts[name_]:= GAAccount[Py["m.account_by_title('"~~name~~"')"]];

GADateStringConvert[date_] :=
	ToExpression /@
		StringCases[date, RegularExpression["(\d{4})(\d{2})(\d{2})"] -> {"$1","$2","$3"}][[1]];

GADateConvert[data_]:= Function[{entry},
	Map[ReleaseHold,
		ReplaceList[entry,
			{s___, "date" -> d_, e___} -> 
				{s, "date" -> 
					Hold[GADateStringConvert[d]],e}][[1]]]] /@ data;

GAConvert[dim_, met_, rawdata_] := Module[{data},
	(* turn each data row into mapping of metrics and dimensions to respective values *)
	data = Function[{d},
			Join[MapThread[#1 -> #2 &, {dim, d[[1]]}],
				 MapThread[#1 -> #2 &, {met, d[[2]]}]]] /@ rawdata;
	If[MemberQ[dim, "date"], GADateConvert[data], data]
];

EnsureList[x_List] := x
EnsureList[x_] := {x}

GAData[ac_GAAccount, start_, end_, rawdim_, rawmet_] := Module[
	{dim = EnsureList[rawdim],
	 met = EnsureList[rawmet]},
	ToPy["_start", start];
	ToPy["_end", end];
	ToPy["_ac", Part[ac, 1]];
	ToPy["_dim", dim];
	ToPy["_met", met];
	GAConvert[dim, met, Py["m.get_data(_ac, _start, _end, dimensions=_dim, metrics=_met)"]]
];

GAGroupBy[prop_, data_, opts___?OptionQ] := Module[{collatep, collatef},
	{collatep, collatef} = {CollateProperty, CollateFunction} /. Flatten[{opts, Options[GAGroupBy]}];
	Function[{day},
		{(prop /. day[[1]]), collatef[(collatep /. #) & /@ day]}] /@ GAGatherBy[prop, data]
];

Options[GAGroupBy] = {CollateProperty -> "visits", CollateFunction -> Total};

GAGatherBy[metric_, data_]:=
	GatherBy[data, metric /. # &];

GASelect[prop_, test_, data_] := Select[data, test[(prop /. #)] &];

EndPackage[];
