using System;
using System.IO;
using System.Text;

namespace RawBinaryToMif
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var binaryFileName = args[0];

            Console.Write($"Converting file {binaryFileName}... ");

            var sb = new StringBuilder();

            sb.AppendLine(
@"WIDTH = 16;
DEPTH = 256;

ADDRESS_RADIX = UNS;
DATA_RADIX = HEX;

CONTENT BEGIN");

            var bytes = File.ReadAllBytes(binaryFileName);

            for (var i = 0; i < bytes.Length; i += 2)
            {
                sb.AppendLine($"    {i / 2} : {bytes[i + 1]:X2}{bytes[i]:X2};");
            }

            sb.AppendLine("END;");

            var mifFileName = Path.ChangeExtension(binaryFileName, ".mif");
            File.WriteAllText(mifFileName, sb.ToString());

            Console.WriteLine("done.");
            Console.ReadLine();
        }
    }
}
