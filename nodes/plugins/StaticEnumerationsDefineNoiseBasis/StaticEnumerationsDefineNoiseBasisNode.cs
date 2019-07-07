#region usings
using System;
using System.ComponentModel.Composition;

using VVVV.PluginInterfaces.V1;
using VVVV.PluginInterfaces.V2;
using VVVV.Utils.VColor;
using VVVV.Utils.VMath;

using VVVV.Core.Logging;
#endregion usings

namespace VVVV.Nodes
{

	public enum NoiseBasis
	{
		random, sine, valueNoise, perlin, simplex, worleyFast, worley
	}
	
	public enum NoiseInflection
	{
		None, Billow, Ridge
	}
	
	public enum WorleyDistanceMetric
	{
		EuclideanSquared, Euclidean, Chebyshev, Manhattan, Minkowski, Cubes
	}
	
	public enum WorleyFunction
	{
		F1, F2, F2MinusF1, F1PlusF2, Average, Crackle
	}


	#region PluginInfo
	[PluginInfo(Name = "DefineNoiseBasis", Category = "Enumerations", Version = "Static", Help = "Basic template with native .NET enum type", Tags = "c#")]
	#endregion PluginInfo
	public class StaticEnumerationsDefineNoiseBasisNode : IPluginEvaluate
	{
		#region fields & pins
		[Input("Basis", DefaultEnumEntry = "perlin")]
		public IDiffSpread<NoiseBasis> FInBasis;

		[Input("Inflection", DefaultEnumEntry = "None")]
		public IDiffSpread<NoiseInflection> FInInflection;
		
		[Input("Worley Distance Metric", DefaultEnumEntry = "EuclideanSquared")]
		public IDiffSpread<WorleyDistanceMetric> FInWorleyMetric;
		
		[Input("Worley Function", DefaultEnumEntry = "F2MinusF1")]
		public IDiffSpread<WorleyFunction> FInWorleyFunc;
		
		[Output("Basis")]
		public ISpread<string> FBasisOutput;
		
		[Output("Inflection")]
		public ISpread<int> FInflectionOutput;
		
		[Output("Worley Distance Metric")]
		public ISpread<string> FWorleyMetricOutput;
		
		[Output("Worley Function")]
		public ISpread<string> WorleyFuncOutput;

		[Output("Defines")]
		public ISpread<string> DefinesOutput;

		[Import()]
		public ILogger Flogger;
		#endregion fields & pins

		//called when data for any output pin is requested
		public void Evaluate(int SpreadMax)
		{

			if (FInBasis.IsChanged) FBasisOutput[0] = Enum.GetName(typeof(NoiseBasis), FInBasis[0]);
			if (FInInflection.IsChanged) FInflectionOutput[0] = (int)FInInflection[0];
			if (FInWorleyMetric.IsChanged) FWorleyMetricOutput[0] = Enum.GetName(typeof(WorleyDistanceMetric), FInWorleyMetric[0]);
			if (FInWorleyFunc.IsChanged) WorleyFuncOutput[0] = Enum.GetName(typeof(WorleyFunction), FInWorleyFunc[0]);
		}
	}
}
