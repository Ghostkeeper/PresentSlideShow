<?xml version="1.0" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html" doctype-system="about:legacy-compat" encoding="UTF-8" indent="yes" media-type="text/html" />

<xsl:template match="/">
	<html>
		<head>
			<title><xsl:value-of select="presentation/@title" /></title>
			<meta http-equiv="X-UA-Compatible" content="IE=edge" /> <!-- Prevent IE from entering compatibility mode. -->
			<link rel="stylesheet" type="text/css" href="presentation.css" />
			<script type="text/javascript" src="presentation.js" />
			<script type="text/javascript">
				//Fill some Javascript globals with XML data.
				numitems = [];
				<xsl:for-each select="presentation/category/slide">
					numitems[<xsl:value-of select="position() - 1" />] = <xsl:value-of select="count(item)" />;
				</xsl:for-each>
				numslides = <xsl:value-of select="count(presentation/category/slide)" />
			</script>
		</head>
		<body onClick="nextItem()" onLoad="init()">
			<!-- Logo is always on top of every slide. -->
			<xsl:if test="presentation/logo">
				<div class="logo">
					<img width="100%">
						<xsl:attribute name="src"><xsl:value-of select="//presentation/@resources" /><xsl:value-of select="presentation/logo" /></xsl:attribute>
					</img>
				</div>
			</xsl:if>

			<xsl:for-each select="presentation/category/slide">
				<xsl:variable name="slidenr"><xsl:value-of select="position() - 1" /></xsl:variable>

				<!-- Slide-wide script that gets executed upon displaying the slide. -->
				<xsl:if test="script">
					<script type="text/javascript">
						function event<xsl:value-of select="count(preceding::slide)" />() {
							<xsl:value-of select="script" />
						}
					</script>
				</xsl:if>
				<div style="position: absolute; left: 0px; top: 0px; width: 100%; height: 100%; visibility: hidden; opacity: 0; filter: alpha(opacity=0); background-color: #FFFFFF">
					<xsl:attribute name="id">slide<xsl:value-of select="$slidenr" /></xsl:attribute>

					<!-- Header with the title of the slide in it. -->
					<div class="header">
						<xsl:attribute name="id">header<xsl:value-of select="$slidenr" /></xsl:attribute>
						<xsl:if test="@titlefont">
							<xsl:attribute name="style">font-family: <xsl:value-of select="@titlefont" /></xsl:attribute>
						</xsl:if>
						<xsl:value-of select="@title" />
					</div>

					<!-- Main content of the slide.
					Note that this content gets rescaled with the window width. -->
					<div class="content" style="height: 100%">
						<xsl:attribute name="style">
							height: 100%
						</xsl:attribute>
						<xsl:if test="background">
							<xsl:attribute name="style">background-image: url('<xsl:value-of select="//presentation/@resources" /><xsl:value-of select="background" />')</xsl:attribute>
						</xsl:if>

						<!-- Some padding to keep distance between header and content. -->
						<xsl:if test="not(item/video) and not(@nonewline)">
							<br />
						</xsl:if>

						<!-- Display each item, either vertically or horizontally. -->
						<xsl:choose>
							<xsl:when test="@vertical">
								<!-- When displaying vertically, the first item still gets shown as a row (horizontally).
								You can use this to create a header bar, or just for the initial part.

								I've found that in my presentations, if there is a vertical layout, I typically use it for
								enumerations. In those enumerations it gives the listener some breathing room if you don't
								start enumerating immediately upon initial loading of the slide. You can tell what you're
								going to enumerate while displaying this initial horizontal item.-->
								<!-- Initially, all items are hidden until they are revealed by the nextItem() function. -->
								<div class="item" style="visibility: hidden; opacity: 0; filter: alpha(opacity=0)">
									<xsl:attribute name="id">slide<xsl:value-of select="$slidenr" />item0</xsl:attribute>
									<xsl:attribute name="in">
										<xsl:choose>
											<xsl:when test="starts-with(@in, 'fade')">fade</xsl:when>
											<xsl:when test="starts-with(@in, 'slide')">slide<xsl:value-of select="substring(@in, 6)" /></xsl:when>
											<xsl:otherwise>fade</xsl:otherwise>
										</xsl:choose>
									</xsl:attribute>
									<xsl:apply-templates select="item[1]" />
								</div>
								<!-- Display the rest of the items underneath in a table. -->
								<table style="width: 94%; margin-left: 3%; height: 100%"> <!-- Height is too high, but we hide scroll bars anyway. -->
									<tr style="height: 100%">
										<xsl:for-each select="item[position() > 1]">
											<!-- Initially, all items are hidden until they are revealed by the nextItem() function. -->
											<td class="item" style="visibility: hidden; opacity: 0; filter: alpha(opacity=0); height: 100%">
												<xsl:attribute name="id">slide<xsl:value-of select="$slidenr" />item<xsl:value-of select="position()" /></xsl:attribute>
												<!-- Communicate to JavaScript how we should transition in the item.
												If it's a slide-in, we must position it differently. -->
												<xsl:attribute name="in">
													<xsl:choose>
														<xsl:when test="starts-with(@in, 'fade')">fade</xsl:when>
														<xsl:when test="starts-with(@in, 'slide')">slide<xsl:value-of select="substring(@in, 6)" /></xsl:when>
														<xsl:otherwise>fade</xsl:otherwise>
													</xsl:choose>
												</xsl:attribute>
												<xsl:choose>
													<xsl:when test="@width">
														<!-- @width attribute is relative to the "normal" evenly-spaced width.
														Setting a width of 200% will cause this item to be twice as wide as the normal ones that had 100% or those that didn't specify any width. -->
														<xsl:attribute name="width"><xsl:value-of select="number(@width) div (count(../item) - 1)" />%</xsl:attribute>
													</xsl:when>
													<xsl:otherwise>
														<xsl:attribute name="width"><xsl:value-of select="number(100) div (count(../item) - 1)" />%</xsl:attribute>
													</xsl:otherwise>
												</xsl:choose>
												<xsl:apply-templates select="." />
											</td>
										</xsl:for-each>
									</tr>
								</table>
							</xsl:when>
							<xsl:otherwise>
								<!-- Display all items as rows: Divs just underneath each other. -->
								<xsl:for-each select="item">
									<!-- Initially, all items are hidden until they are revealed by the nextItem() function. -->
									<div class="item" style="visibility: hidden; opacity: 0; filter: alpha(opacity=0)">
										<xsl:attribute name="id">slide<xsl:value-of select="$slidenr" />item<xsl:value-of select="position() - 1" /></xsl:attribute>
										<xsl:attribute name="in">
											<xsl:choose>
												<xsl:when test="starts-with(@in, 'fade')">fade</xsl:when>
												<xsl:when test="starts-with(@in, 'slide')">slide<xsl:value-of select="substring(@in, 6)" /></xsl:when>
												<xsl:otherwise>fade</xsl:otherwise>
											</xsl:choose>
										</xsl:attribute>
										<xsl:apply-templates select="." />
									</div>
								</xsl:for-each>
							</xsl:otherwise>
						</xsl:choose>
					</div>

					<!-- Footer, displaying the category and the slide count. -->
					<div class="footer">
						<xsl:attribute name="id">footer<xsl:value-of select="$slidenr" /></xsl:attribute>
						<div class="footerleft">
							<!-- Category name! Not slide name. -->
							<xsl:value-of select="../@name" />
						</div>
						<div class="footerright">
							<!-- Current slide index out of total slide count. -->
							<xsl:value-of select="$slidenr + 1" /> / <xsl:value-of select="count(/presentation/category/slide)" />
						</div>
					</div>
				</div>
			</xsl:for-each>
			<div class="footer" style="z-index: -100"> <!-- Footer is always on top. -->
				<div class="footerleft" style="z-index: -100">&#160;</div>
				<div class="footerright" style="z-index: -100">&#160;</div>
			</div>
		</body>
	</html>
</xsl:template>

<!--
The following templates are for matching the contents in an item.
These tags are the only ones allowed in an <item> tag. The rest is ignored.
-->

<!-- For displaying plain text in an item. -->
<xsl:template match="text">
	<div class="text">
		<xsl:attribute name="style">
			<xsl:if test="@size">
				font-size: <xsl:value-of select="@size" />;
			</xsl:if>
			<xsl:if test="@align">
				text-align: <xsl:value-of select="@align" />;
			</xsl:if>
			<xsl:if test="@margin">
				padding-left: <xsl:value-of select="@margin" />
			</xsl:if>
		</xsl:attribute>
		<xsl:copy-of select="." />
	</div>
</xsl:template>

<!-- Displays a bullet point in front of the text.
The @align and @margin properties are not allowed for bullet points.
Otherwise this tag is identical to <text>. -->
<xsl:template match="bullet">
	<ul>
		<li>
			<xsl:attribute name="style">
				<xsl:if test="@size">
					font-size: <xsl:value-of select="@size" />
				</xsl:if>
			</xsl:attribute>
			<xsl:copy-of select="." />
		</li>
	</ul>
</xsl:template>

<!-- Display an image.
Normally images are displayed very big at 90% the width of the screen.
It is up to the presenter to make sure that the aspect ratio of the image allows the entire image to show up on his beamer. -->
<xsl:template match="image">
	<div class="image">
		<img>
			<xsl:choose>
				<xsl:when test="@width">
					<xsl:attribute name="width"><xsl:value-of select="@width" /></xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="width">90%</xsl:attribute>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="@height">
				<xsl:attribute name="height"><xsl:value-of select="@height" /></xsl:attribute>
			</xsl:if>
			<xsl:attribute name="src"><xsl:value-of select="//presentation/@resources" /><xsl:value-of select="." /></xsl:attribute>
		</img>
	</div>
</xsl:template>

<!-- Display a "video".
Actually this just displays an iframe. You could put anything in here.
It's intended and tested to work with YouTube. -->
<xsl:template match="video">
	<iframe width="100%" frameborder="0" allowfullscreen="yes">
		<xsl:attribute name="src"><xsl:value-of select="//presentation/@resources" /><xsl:value-of select="." /></xsl:attribute>
	</iframe>
</xsl:template>

<!-- Display an actual video and loop it.
This is intended to function sort of like a GIF image but more efficient with large files.
Use it for an impressive pre-rendered animation in your slide. -->
<xsl:template match="videoloop">
	<div align="center">
		<video loop="yes" autoplay="yes">
			<xsl:attribute name="width">
				<xsl:choose>
					<xsl:when test="@width">
						<xsl:value-of select="@width" />
					</xsl:when>
					<xsl:otherwise>
						90%
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<source type="video/ogg">
				<xsl:attribute name="src"><xsl:value-of select="//presentation/@resources" /><xsl:value-of select="." /></xsl:attribute>
			</source>
			OGG/Theora video codec not supported.
		</video>
	</div>
</xsl:template>

<!-- JavaScript snippet that gets executed when the item is loaded. -->
<xsl:template match="script">
	<script type="text/javascript">
		function event<xsl:value-of select="count(preceding::slide)" />x<xsl:value-of select="count(../preceding-sibling::item)" />() {
			<xsl:value-of select="." />
		}
	</script>
</xsl:template>

<!-- Displays the current time. -->
<xsl:template match="clock">
	<div class="text">
		<div class="clock">??:??:??</div>
	</div>
</xsl:template>

</xsl:stylesheet>
