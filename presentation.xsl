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
				numitems = [];
				<xsl:for-each select="presentation/category/slide">
					numitems[<xsl:value-of select="position() - 1" />] = <xsl:value-of select="count(item)" />;
				</xsl:for-each>
				numslides = <xsl:value-of select="count(presentation/category/slide)" />
			</script>
		</head>
		<body onClick="nextItem()" onLoad="init()">
			<xsl:if test="presentation/logo">
				<div class="logo">
					<img width="100%">
						<xsl:attribute name="src"><xsl:value-of select="//presentation/@resources" /><xsl:value-of select="presentation/logo" /></xsl:attribute>
					</img>
				</div>
			</xsl:if>
			<xsl:for-each select="presentation/category/slide">
				<xsl:variable name="slidenr"><xsl:value-of select="position() - 1" /></xsl:variable>
				<xsl:if test="script">
					<script type="text/javascript">
						function event<xsl:value-of select="count(preceding::slide)" />() {
							<xsl:value-of select="script" />
						}
					</script>
				</xsl:if>
				<div style="position:absolute; left:0px; top:0px; width:100%; height:100%; visibility:hidden; opacity:0; filter:alpha(opacity=0); background-color: #FFFFFF;">
					<xsl:attribute name="id">slide<xsl:value-of select="$slidenr" /></xsl:attribute>

					<div class="header">
						<xsl:attribute name="id">header<xsl:value-of select="$slidenr" /></xsl:attribute>
						<xsl:if test="@titlefont">
							<xsl:attribute name="style">font-family: <xsl:value-of select="@titlefont" />;</xsl:attribute>
						</xsl:if>
						<xsl:value-of select="@title" />
					</div>
					
					<div class="content" style="height:100%;">
						<xsl:attribute name="style">
							height: 100%;
							<xsl:if test="not(@nonewline)">padding-top: -1em;</xsl:if>
						</xsl:attribute>
						<xsl:if test="background">
							<xsl:attribute name="style">background-image: url('<xsl:value-of select="//presentation/@resources" /><xsl:value-of select="background" />')</xsl:attribute>
						</xsl:if>
						
						<xsl:if test="not(item/video)">
							<br />
						</xsl:if>
						
						<xsl:choose>
							<xsl:when test="@vertical">
								<div class="item" style="visibility:hidden; opacity:0; filter:alpha(opacity=0);">
									<xsl:attribute name="id">slide<xsl:value-of select="$slidenr" />item0</xsl:attribute>
									<xsl:attribute name="in">
										<xsl:choose>
											<xsl:when test="starts-with(@in,'fade')">fade</xsl:when>
											<xsl:when test="starts-with(@in,'slide')">slide<xsl:value-of select="substring(@in,6)" /></xsl:when>
											<xsl:otherwise>fade</xsl:otherwise>
										</xsl:choose>
									</xsl:attribute>
									<xsl:apply-templates select="item[1]" />
								</div>
								<table style="width:94%; margin-left:3%; height:100%;">
									<tr style="height:100%;">
										<xsl:for-each select="item[position() > 1]">
											<td class="item" style="visibility:hidden; opacity:0; filter:alpha(opacity=0); height:100%">
												<xsl:attribute name="id">slide<xsl:value-of select="$slidenr" />item<xsl:value-of select="position()" /></xsl:attribute>
												<xsl:attribute name="in">
													<xsl:choose>
														<xsl:when test="starts-with(@in,'fade')">fade</xsl:when>
														<xsl:when test="starts-with(@in,'slide')">slide<xsl:value-of select="substring(@in,6)" /></xsl:when>
														<xsl:otherwise>fade</xsl:otherwise>
													</xsl:choose>
												</xsl:attribute>
												<xsl:choose>
													<xsl:when test="@width">
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
								<xsl:for-each select="item">
									<div class="item" style="visibility:hidden; opacity:0; filter:alpha(opacity=0);">
										<xsl:attribute name="id">slide<xsl:value-of select="$slidenr" />item<xsl:value-of select="position() - 1" /></xsl:attribute>
										<xsl:attribute name="in">
											<xsl:choose>
												<xsl:when test="starts-with(@in,'fade')">fade</xsl:when>
												<xsl:when test="starts-with(@in,'slide')">slide<xsl:value-of select="substring(@in,6)" /></xsl:when>
												<xsl:otherwise>fade</xsl:otherwise>
											</xsl:choose>
										</xsl:attribute>
										<xsl:apply-templates select="." />
									</div>
								</xsl:for-each>
							</xsl:otherwise>
						</xsl:choose>
					</div>
					
					<div class="footer">
						<xsl:attribute name="id">footer<xsl:value-of select="$slidenr" /></xsl:attribute>
						<div class="footerleft">
							<xsl:value-of select="../@name" />
						</div>
						<div class="footerright">
							<xsl:value-of select="$slidenr + 1" /> / <xsl:value-of select="count(/presentation/category/slide)" />
						</div>
					</div>
				</div>
			</xsl:for-each>
			<div class="footer" style="z-index: -100;">
				<div class="footerleft" style="z-index: -100;">&#160;</div>
				<div class="footerright" style="z-index: -100;">&#160;</div>
			</div>
		</body>
	</html>
</xsl:template>

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
				padding-left: <xsl:value-of select="@margin" />;
			</xsl:if>
		</xsl:attribute>
		<xsl:copy-of select="." />
	</div>
</xsl:template>

<xsl:template match="bullet">
	<ul>
		<li>
			<xsl:attribute name="style">
				<xsl:if test="@size">
					font-size: <xsl:value-of select="@size" />;
				</xsl:if>
			</xsl:attribute>
			<xsl:copy-of select="." />
		</li>
	</ul>
</xsl:template>

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

<xsl:template match="video">
	<iframe width="100%" frameborder="0" allowfullscreen="yes">
		<xsl:attribute name="src"><xsl:value-of select="." /></xsl:attribute>
	</iframe>
</xsl:template>

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

<xsl:template match="script">
	<script type="text/javascript">
		function event<xsl:value-of select="count(preceding::slide)" />x<xsl:value-of select="count(../preceding-sibling::item)" />() {
			<xsl:value-of select="." />
		}
	</script>
</xsl:template>

<xsl:template match="clock">
	<div class="text">
		<div class="clock">??:??:??</div>
	</div>
</xsl:template>

</xsl:stylesheet>