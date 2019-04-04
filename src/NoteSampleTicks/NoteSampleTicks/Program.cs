using System;
using System.Collections.Generic;
using System.IO;

namespace NoteSampleTicks
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var lines = new List<string>();

            for (var i = 0; i < 128; i++)
            {
                var frequency = 440 / 32d * Math.Pow(2, (i - 9) / 12d);
                var ticks = 50000000 / frequency / 256;
                var line = $"8'h{i:X2}: noteSampleTicks <= 24'd{(int)ticks};  // {i}";
                lines.Add(line);
                Console.WriteLine(line);
            }

            File.WriteAllLines("output.txt", lines);
            Console.WriteLine("Done.");

            Console.ReadLine();
        }
    }
}
