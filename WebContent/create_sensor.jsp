<%@ page import="java.io.*" 
%><%@ page import="java.awt.*"
%><%@ page import="java.awt.image.*"
%><%@ page import="javax.imageio.*"
%><%@ page import="javax.swing.JPanel"
%><%@ page import="photons.*"
%><%
String fNo = request.getParameter("f");
String l = request.getParameter("l");
int[] into = null; 
if (request.getParameterMap().containsKey("x1")) {
	int x1 = Integer.parseInt(request.getParameter("x1"));
	int y1 = Integer.parseInt(request.getParameter("y1"));
	int w = Integer.parseInt(request.getParameter("w"));
	int h = Integer.parseInt(request.getParameter("h"));
	into = new int[]{x1, y1, w, h};
}

String wantedImage = request.getParameter("img");
String wantedIll = request.getParameter("ill");
if (wantedIll == null) {
	wantedIll = "D65.mat";
	System.out.println("wtfmissingill");
}
if (wantedImage == null) {
	wantedImage = "hats.jpg";
	System.out.println("wtfmissingimg");
}
System.out.println("wantedImage");
System.out.println("wantedIll");
int[][][] rgbArray = Images.getSensor(wantedImage, wantedIll, into, fNo, l);
int WIDTH = rgbArray[0].length; 
int HEIGHT = rgbArray.length;

BufferedImage image =
    new BufferedImage(WIDTH,
                      HEIGHT,
                      BufferedImage.TYPE_INT_RGB);
Graphics g = image.createGraphics();

// this code from https://sites.google.com/site/drjohnbmatthews/raster
int[] iArray = { 0, 0, 0, 255 };

WritableRaster raster = image.getRaster();
for (int row = 0; row < HEIGHT; row++) {
  for (int col = 0 ; col < WIDTH; col++) {
    iArray[0] = rgbArray[row][col][0];
    iArray[1] = rgbArray[row][col][1];
    iArray[2] = rgbArray[row][col][2];
    raster.setPixel(col, row, iArray);
  }
}
g.drawImage(image, 0, 0, WIDTH, HEIGHT, null);
// end source

response.setContentType("image/png");
OutputStream os = response.getOutputStream();
ImageIO.write(image, "png", os);
os.close();
// source: http://today.java.net/pub/a/today/2004/04/22/images.html
%>