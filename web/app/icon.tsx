// Favicon: een Z in koper op nacht, in het eigen palet (geen logo)
import { ImageResponse } from "next/og";

export const size = { width: 64, height: 64 };
export const contentType = "image/png";

export default function Icoon() {
  return new ImageResponse(
    (
      <div style={{ width: "100%", height: "100%", background: "#070B18", color: "#D08A55", display: "flex", alignItems: "center", justifyContent: "center", fontSize: 46, borderRadius: 12 }}>
        Z
      </div>
    ),
    size,
  );
}
