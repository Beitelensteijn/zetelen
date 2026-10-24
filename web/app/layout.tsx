import type { Metadata } from "next";
import { DM_Mono, Hanken_Grotesk, Newsreader } from "next/font/google";
import type { ReactNode } from "react";
import { Korrel } from "@/components/Onderdelen";
import "@/styles/globals.css";

// next/font haalt de lettertypes bij het bouwen op en levert ze zelf uit:
// bezoekers maken geen verbinding met Google
const newsreader = Newsreader({
  subsets: ["latin"],
  style: ["normal", "italic"],
  axes: ["opsz"],
  variable: "--font-newsreader",
  display: "swap",
});
const hanken = Hanken_Grotesk({ subsets: ["latin"], variable: "--font-hanken", display: "swap" });
const dmMono = DM_Mono({ subsets: ["latin"], weight: ["400", "500"], variable: "--font-dm-mono", display: "swap" });

export const metadata: Metadata = {
  title: "Zetelen",
  description: "Hoe vaak stemmen fracties in de Tweede Kamer hetzelfde? Op basis van de open data van de Kamer.",
};

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="nl" className={`${newsreader.variable} ${hanken.variable} ${dmMono.variable}`}>
      <body>
        <Korrel />
        {children}
      </body>
    </html>
  );
}
