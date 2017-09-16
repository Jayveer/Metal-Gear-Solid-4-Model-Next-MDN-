-- made by Jayveer for savemgo.com
-- if you are interested in reversing Metal Gear Solid games join our discord 
-- https://discord.gg/rKRVz76

clearlistener()

fn getPos fstream = (
	print ("At offset 0x" + (bit.intAsHex(ftell fstream)) as string)
)

fn byteAlign size fstream = (
	skip = (size - (mod (ftell fstream) size))
	
	if skip != size then (
		fseek fstream skip #seek_cur
	)	
)

fn readBElong fstream = (
long = readlong fstream
long = bit.swapBytes long 1 4
long = bit.swapBytes long 2 3
return long
)

fn readBEshort fstream = (
short = readshort fstream #unsigned
short = bit.swapBytes short 1 2
return short
)

fn readHalfFloat fstream = (
    hf=readBEshort fstream
    sign = bit.get hf 16
    exponent = (bit.shift (bit.and hf (bit.hexasint "7C00")) -10) as integer - 16
    fraction = bit.and hf (bit.hexasint "03FF")
    if sign==true then sign = 1 else sign = 0
    exponentF = exponent + 127
    outputAsFloat = bit.or (bit.or (bit.shift fraction 13) \
    (bit.shift exponentF 23)) (bit.shift sign 31)
    return bit.intasfloat outputasfloat*2
)
	
fn ReadBEfloat fstream = (
    fpt=readfloat fstream
    itger = bit.floatAsInt fpt
    hih = bit.intashex itger
    while hih.count < 8 do hih = "0" + hih
    shn = (substring hih 7 2) + \
    (substring hih 5 2) + \
    (substring hih 3 2) + \
    (substring hih 1 2)
    bit.intAsFloat (bit.hexasint shn)
)

fn colorMesh mesh = (
	mesh.wirecolor =  color (random 0 255) (random 0 255) (random 0 255)
)

fsource = GetOpenFileName \
caption:"Select mdn File" \
types: "Model Next(*.mdn)|*.mdn|All files (*.*)|*.*|"
if fsource != undefined then (
f = fopen fsource "rb"
	
vertexBuffer =#()
faceBuffer =#()
uvBuffer = #()
altUVBuffer= #()
weightBuffer = #()
boneBuffer = #()
materialBuffer = #()
colourBuffer =#()
tempBuffer = #()
tempBuffer2 =#()
tempBuffer3 = #()
tempBuffer4 =#()
tempBuffer5 =#()
tempBuffer6 =#()

fn fillUVBufferIfEmpty int = (
	if uvBuffer[int].count == 0 Do (
		for z = 1 to vertexBuffer[int].count Do (
			append uvBuffer[int] [0,0,0]
		)
	)
)


struct Header (
	magic,
	filename,
	boneCount,
	meshGroupCount,
	meshCount,
	faceCount,
	vertDefCount,
	materialCount,
	textureCount,
	bonePalletCount,
	boneOffset,
	meshGroupOffset,
	vertCountOffset,
	faceCountOffset,
	vertDefOffset,
	count6Offset,
	materialOffset,
	bonePalletOffset,
	vertexBufferOffset,
	vertexBufferSize,
	faceBufferOffset,
	faceBufferSize,
	nullbytes,
	filesize
)

struct MdnBoundary (
	x,
	y,
	z,
	w,
	x2,
	y2,
	z2,
	w2
)

struct MdnBones (
	hashName,
	y0,
	parent,
	w0,
	rotX,
	rotY,
	rotZ,
	rotW,
	posX,
	posY,
	posZ,
	posW,
	sclX,
	sclY,
	sclZ,
	sclW,
	sclX2,
	sclY2,
	sclZ2,
	sclW2
)

struct MdnMeshGroup (
	hashName,
	nullbytes,
	parent,
	unknown
)

struct MdnVertCountIndex (
	meshGroupIdx,
	unknown2,
	faceSectionCount,
	faceSectionStart,
	vertexId,
	bonePalletId,
	vertexCount,
	nullBytes,
	maxX,
	maxY,
	maxZ,
	maxW,
	minX,
	minY,
	minZ,
	minW,
	posX,
	posY,
	posZ,
	posW
)

struct MdnFaceIndex (
	type,
	count,
	offset,
	matGroup,
	start,
	size
)

struct MdnVertexDefinition (
	
	nullBytes,
	defintionCount,
	size,
	start,
	definition,
	position
)

struct MdnMaterialIndex (
	flag,
	hashName,
	textureCount,
	colourCount,
	diffuseIndex,
	normalIndex,
	specularIndex,
	filterIndex,
	ambientIndex,
	specGradientIndex,
	wrinkleIndex,
	unknown2Index,
	diffuseR,
	diffuseG,
	diffuseB,
	diffuseA,
	specularR,
	specularG,
	specularB,
	specularA,
	unknownR,
	unknownG,
	unknownB,
	unknownA,
	unknownR2,
	unknownG2,
	unknownB2,
	unknownA2,
	unknownR3,
	unknownG3,
	unknownB3,
	unknownA3,
	unknownR4,
	unknownG4,
	unknownB4,
	unknownA4,
	unknownR5,
	unknownG5,
	unknownB5,
	unknownA5,
	unknownR6,
	unknownG6,
	unknownB6,
	unknownA6
)

struct MdnTextureIndex (
	
	hashName,
	x,
	y,
	z,
	nullBytes,
	nullBytes2
	
)

struct MdnBonePallet (
	unknown,
	count,
	nullbytes,
	boneId
)

-------------------header--------------------------
mdnHeader = Header()

mdnHeader.magic = readBElong f
mdnHeader.filename = readBElong f
mdnHeader.boneCount = readBElong f
mdnHeader.meshGroupCount = readBElong f
mdnHeader.meshCount = readBElong f
mdnHeader.faceCount = readBElong f
mdnHeader.vertDefCount = readBElong f
mdnHeader.materialCount = readBElong f
mdnHeader.textureCount = readBElong f
mdnHeader.bonePalletCount = readBElong f
mdnHeader.boneOffset = readBElong f
mdnHeader.meshGroupOffset = readBElong f
mdnHeader.vertCountOffset = readBElong f
mdnHeader.faceCountOffset = readBElong f
mdnHeader.vertDefOffset = readBElong f
mdnHeader.count6Offset = readBElong f
mdnHeader.materialOffset = readBElong f
mdnHeader.bonePalletOffset = readBElong f
mdnHeader.vertexBufferOffset = readBElong f
mdnHeader.vertexBufferSize = readBElong f
mdnHeader.faceBufferOffset = readBElong f
mdnHeader.faceBufferSize = readBElong f
mdnHeader.nullbytes = readBElong f
mdnHeader.filesize = readBElong f


-------------------boundary--------------------------
boundary = MdnBoundary()

boundary.x =readBEfloat f 
boundary.y =readBEfloat f 
boundary.z =readBEfloat f 
boundary.w =readBEfloat f

boundary.x2 =readBEfloat f 
boundary.y2 =readBEfloat f 
boundary.z2 =readBEfloat f 
boundary.w2 =readBEfloat f

-------------------bones------------------------------

boneIdx = #()

for i = 1 to mdnHeader.boneCount do (
	theBones = MdnBones()
	theBones.hashName = readBElong f
	theBones.y0 = readBElong f
	theBones.parent  = readBElong f + 1
	theBones.w0  = readBElong f
	theBones.rotX = readBEfloat f
	theBones.rotY = readBEfloat f
	theBones.rotZ  = readBEfloat f
	theBones.rotW  = readBEfloat f
	theBones.posX  = readBEfloat f
	theBones.posY  = readBEfloat f
	theBones.posZ = readBEfloat f
	theBones.posW = readBEfloat f
	theBones.sclX  = readBEfloat f
	theBones.sclY  = readBEfloat f
	theBones.sclZ  = readBEfloat f
	theBones.sclW  = readBEfloat f
	theBones.sclX2  = readBEfloat f
	theBones.sclY2  = readBEfloat f
	theBones.sclZ2  = readBEfloat f
	theBones.sclW2 = readBEfloat f

	append boneIdx theBones

)

for i = 1 to mdnHeader.boneCount do (
	rx =	boneIdx[i].rotX;	 ry = boneIdx[i].rotY; 		rz = boneIdx[i].rotZ; 	 rw = boneIdx[i].rotW
	px =	boneIdx[i].posX; 	 py = boneIdx[i].posY;		pz = boneIdx[i].posZ;	 pw = boneIdx[i].posW
	sx =	boneIdx[i].sclX;	 sy = boneIdx[i].sclY; 		sz = boneIdx[i].sclZ;	 sw = boneIdx[i].sclW
	qx =	boneIdx[i].sclX2;	 qy = boneIdx[i].sclY2; 	qz = boneIdx[i].sclZ2;	 qw = boneIdx[i].sclW2
	
	BoneRot = (quat rw ry rx rz) as matrix3
	BonePos = [px,py,pz, pw]
	
	bne = dummy showLinks:true showLinksOnly:true
	
	bne.name = bit.intAsHex(boneIdx[i].hashName) as string
	bne.rotation = BoneRot
	bne.pos = BonePos
	
	if (boneIdx[i].parent  != 0) then bne.parent = getNodeByName (bit.intAsHex(boneIdx[(boneIdx[i].parent)].hashName) as string)
	
)

---------------meshgroup------------------------

meshGroup = #()

for i =1 to mdnHeader.meshGroupCount do (
	mshGrp = MdnMeshGroup()
	
	mshGrp.hashName = readBElong f
	mshGrp.nullbytes  = readBElong f
	mshGrp.parent = readBElong f + 1
	mshGrp.unknown = readBElong f
	
	append meshGroup mshGrp
)

for i = 1 to mdnHeader.meshGroupCount do (
		layer = LayerManager.newLayer()
		layer.setname (bit.intAsHex(meshGroup[i].hashName) as string)
		if (meshGroup[i].parent != 0) then (
			parentLayer = LayerManager.getLayerFromName ((bit.intAsHex(meshGroup[(meshGroup[i].parent)].hashName) as string))
			layer.setParent parentLayer 
		) 
)

------------------vertexcountIndex-------------------

vertCountIdx = #()

for i = 1 to mdnHeader.meshCount do (
	vCount = MdnVertCountIndex()
	
	vCount.meshGroupIdx = readBElong f
	vCount.unknown2 = readBElong f
	vCount.faceSectionCount = readBElong f
	vCount.faceSectionStart = readBElong f
	vCount.vertexId = readBElong f
	vCount.bonePalletId = readBElong f
	vCount.vertexCount = readBElong f
	vCount.nullBytes = readBElong f
	vCount.maxX = readBEfloat f
	vCount.maxY = readBEfloat f
	vCount.maxZ = readBEfloat f
	vCount.maxW = readBEfloat f
	vCount.minX = readBEfloat f
	vCount.minY = readBEfloat f
	vCount.minZ = readBEfloat f
	vCount.minW = readBEfloat f
	vCount.posX = readBEfloat f
	vCount.posY = readBEfloat f
	vCount.posZ = readBEfloat f
	vCount.posW = readBEfloat f
	
	append vertCountIdx vCount
	
)

----------------faceIndex----------------------

faceCountIdx = #()

for i = 1 to mdnHeader.faceCount do (
	faceDef = MdnFaceIndex()
	faceDef.type = readBEshort f
	faceDef.count = readBEshort f
	faceDef.offset = readBElong f
	faceDef.matGroup = readBElong f
	faceDef.start = readBEshort f
	faceDef.size = readBEshort f
	
	append faceCountIdx faceDef
)



-----------vertexDefIndex-------------------

vertDefIdx = #()

for i = 1 to mdnHeader.vertDefCount do (

	vDef = MdnVertexDefinition()
	
	vDef.nullBytes = readBElong f
	vDef.defintionCount = readBElong f
	vDef.size = readBElong f
	vDef.start = readBElong f
	vDef.definition = #()
	vDef.position = #()
	
	for s =1 to vDef.defintionCount do (
		def = readbyte f#unsigned
		append vDef.definition def
	)
	
	fseek f (0x10 - vDef.defintionCount)#seek_cur
	
	for s =1 to vDef.defintionCount do (
		pos = readbyte f#unsigned
		append vDef.position pos
	)
	
	fseek f (0x10 - vDef.defintionCount)#seek_cur
	
	append vertDefIdx vDef
	
)

-----------------materialindex----------------------------
materialIdx = #()

for i = 1 to mdnHeader.materialCount do (

	mat = MdnMaterialIndex()
	
	mat.flag = readBElong f
	mat.hashName = readBElong f
	mat.textureCount = readBElong f
	mat.colourCount = readBElong f
	mat.diffuseIndex = readBElong f
	mat.normalIndex = readBElong f
	mat.specularIndex = readBElong f
	mat.filterIndex = readBElong f
	mat.ambientIndex = readBElong f
	mat.specGradientIndex = readBElong f
	mat.wrinkleIndex = readBElong f
	mat.unknown2Index = readBElong f
	mat.diffuseR = readHalfFloat f * 255
	mat.diffuseG = readHalfFloat f * 255
	mat.diffuseB = readHalfFloat f * 255
	mat.diffuseA = readHalfFloat f * 100
	mat.specularR = readHalfFloat f * 127.5
	mat.specularG = readHalfFloat f * 127.5
	mat.specularB = readHalfFloat f * 127.5
	mat.specularA = readHalfFloat f		
	mat.unknownR = readHalfFloat f
	mat.unknownG = readHalfFloat f
	mat.unknownB = readHalfFloat f
	mat.unknownA = readHalfFloat f
	mat.unknownR2 = readHalfFloat f
	mat.unknownG2 = readHalfFloat f
	mat.unknownB2 = readHalfFloat f
	mat.unknownA2 = readHalfFloat f
	mat.unknownR3 = readHalfFloat f
	mat.unknownG3 = readHalfFloat f
	mat.unknownB3 = readHalfFloat f
	mat.unknownA3 = readHalfFloat f
	mat.unknownR4 = readHalfFloat f
	mat.unknownG4 = readHalfFloat f
	mat.unknownB4 = readHalfFloat f
	mat.unknownA4 = readHalfFloat f
	mat.unknownR5 = readHalfFloat f
	mat.unknownG5 = readHalfFloat f
	mat.unknownB5 = readHalfFloat f
	mat.unknownA5 = readHalfFloat f
	mat.unknownR6 = readHalfFloat f
	mat.unknownG6 = readHalfFloat f
	mat.unknownB6 = readHalfFloat f
	mat.unknownA6 = readHalfFloat f
	
	append materialIdx mat
	
)
------------textureIndex----------------------
textureIdx = #()


for i = 1 to mdnHeader.textureCount do (
	tex = MdnTextureIndex()
	
	tex.hashName = readBElong f
	tex.x = readBEfloat f
	tex.y = readBEfloat f
	tex.z = readBEfloat f
	tex.nullBytes = readlonglong f
	tex.nullBytes2 = readlonglong f
	
	append textureIdx tex
	
)

textureStore =#()
for i = 1 to mdnHeader.textureCount do (
	texture = Bitmaptexture fileName:(sysInfo.currentdir + "\\textures\\" + (bit.intAsHex(textureIdx[i].hashName) as string) + ".dds")
	append textureStore texture
)


mat = multimaterial numsubs: (mdnHeader.materialCount)

for i = 1 to mdnHeader.materialCount do (
	mat[i] = StandardMaterial name:(bit.intAsHex(materialIdx[i].hashName) as string)
	for j = 1 to materialIdx[i].textureCount do ( 
		case (j) of (
			0x1: (
				dIndex = materialIdx[i].diffuseIndex + 1
				mat[i].diffuseMap = textureStore[dIndex]
				
				if materialIdx[i].flag == 0xA3 or materialIdx[i].flag == 0xE0 or materialIdx[i].flag == 0xA6 then (
					mat[i].opacityMap = textureStore[dIndex]
					if materialIdx[i].flag != 0xA6 then (
						textureStore[dIndex].monoOutput = 1
					)
				)
			)
			0x2: (
				nIndex = materialIdx[i].normalIndex + 1
				mat[i].bumpMap = textureStore[nIndex]
			)
			0x3: (
				sIndex = materialIdx[i].specularIndex + 1
				mat[i].specularMap = textureStore[sIndex]
				mat[i].specularLevelMap = textureStore[sIndex]
				mat[i].glossinessMap = textureStore[sIndex]
			)
			0x4: (
				fIndex = materialIdx[i].filterIndex + 1
				mat[i].filterMap = textureStore[fIndex]
			)
			0x5: (
				aIndex = materialIdx[i].ambientIndex + 1
				mat[i].ambientMap = textureStore[aIndex]
			)
			0x6: (
				sGradIndex = materialIdx[i].specGradientIndex + 1
				mat[i].selfillumMap = textureStore[sGradIndex] 
			)
			0x7: (
				wIndex = materialIdx[i].wrinkleIndex + 1
				--would have to add composite material to add wrinkle maps
				--Bitmaptexture fileName:(sysInfo.currentdir + "\\textures\\" + (bit.intAsHex(textureIdx[wIndex].hashName) as string) + ".dds")
			)
			default: (
				print j
				print("I dont know that texture, need to add it")
			)
		)		
	)	
	
	for j = 1 to materialIdx[i].colourCount do ( 
		case (j) of (
			0x1: (
				mat[i].Diffuse = color materialIdx[i].diffuseR materialIdx[i].diffuseG materialIdx[i].diffuseB
				mat[i].opacity = materialIdx[i].diffuseA
			)
			0x2: (
				mat[i].Specular = color materialIdx[i].specularR materialIdx[i].specularG materialIdx[i].specularB
				mat[i].specularLevel = materialIdx[i].specularA
			)
			0x3: (
			)
			default: (
				--print j
				--print("I dont know that colour, need to add it")
			)
		)
	)
	
	mat[i].showInViewPort = on
	mat[i].shaderType = 5
)



-----------bonePalletIndex-----------------------

bonePalletIdx = #()

for i = 1 to mdnHeader.bonePalletCount do (
	
	bonePal = MdnBonePallet ()
	
	bonePal.unknown = readBElong f
	bonePal.count = readBEshort f
	nullbytes = readBEshort f
	bonePal.boneId = #()
	
	for s =1 to bonePal.count do (
		id = readbyte f#unsigned + 1
		append bonePal.boneId id
	)
	
	append bonePalletIdx bonePal
	
	fseek f ((40) - (8 + bonePal.count)) #seek_cur
	
)

byteAlign 0x10 f

---------------------------vertexBuffer--------------------------

for s = 1 to mdnHeader.meshCount do (
	
	for i = 1 to vertCountIdx[s].vertexCount do (
		
		vStart = ftell f
		for j = 1 to vertDefIdx[s].defintionCount  do (
		
			fseek f (vStart + (vertDefIdx[s].position[j])) #seek_set
			
			case (vertDefIdx[s].definition[j]) of (
				0x10:	(
					vX = readBEfloat f
					vY = readBEfloat f
					vZ = readBEfloat f	
					append tempBuffer [vX,vY,vZ]
				)
				0x78: (
					tu = readHalfFloat f
					tv = readHalfFloat f * -1
					append tempBuffer2 [tu,tv,0]
				)
				0x79: (
					tu2 = readHalfFloat f
					tv2 = readHalfFloat f * -1
					append tempBuffer5 [tu2,tv2,0]
				)
				0x7A: (
					tu2 = readHalfFloat f
					tv2 = readHalfFloat f * -1
					append tempBuffer5 [tu2,tv2,0]
				)
				0x81: (
					weight1 = (readbyte f#unsigned / 255.0) as float
					weight2 = (readbyte f#unsigned / 255.0) as float
					weight3 = (readbyte f#unsigned / 255.0) as float
					weight4 = (readbyte f#unsigned / 255.0) as float
					append tempBuffer3 [weight1, weight2, weight3, weight4]
				)
				0x83: (
					colourR = readbyte f#unsigned
					colourG = readbyte f#unsigned
					colourB = readbyte f#unsigned
					colourA = readbyte f#unsigned	
					append tempBuffer6 [colourR, colourG, colourB]
				)
				0x97: (
					bone1 = readbyte f #unsigned
					bone2 = readbyte f #unsigned
					bone3 = readbyte f #unsigned
					bone4 = readbyte f #unsigned
					append tempBuffer4 [bone1, bone2, bone3, bone4]
				)
				0xA2: (
					nx = readbyte f#unsigned
					ny = readbyte f#unsigned
					nz = readbyte f#unsigned
					nw = readbyte f#unsigned	
				)
				0xAE: (
					nx = readbyte f#unsigned
					ny = readbyte f#unsigned
					nz = readbyte f#unsigned
					nw = readbyte f#unsigned	
				)
			)
		)
		fseek f (vStart + (vertDefIdx[s].size)) #seek_set
	)
	append vertexBuffer tempBuffer
	append uvBuffer tempBuffer2
	append weightBuffer tempBuffer3
	append boneBuffer tempBuffer4
	append altUVBuffer tempBuffer5
	append colourBuffer tempBuffer6
	tempBuffer =#()
	tempBuffer2 =#()
	tempBuffer3 =#()
	tempBuffer4 =#()
	tempBuffer5 =#()
	tempBuffer6 =#()
	byteAlign 0x10 f
)


----------------------------faceBuffer------------------------------

for s = 1 to mdnHeader.meshCount do (
	for i = (vertCountIdx[s].faceSectionStart + 1) to (vertCountIdx[s].faceSectionStart + vertCountIdx[s].faceSectionCount) do (
	
		for j = 1 to (faceCountIdx[i].count / 3) Do (
			f1 = (readBEshort f) + 1
			f2 = (readBEshort f) + 1
			f3 = (readBEshort f) + 1
			
			append tempBuffer [f1,f3,f2]
		)
	)
	append faceBuffer tempBuffer
	tempBuffer =#()
)	




---------------------makeMesh------------------------------------------
--for s = 2 to 2 do (
for s = 1 to mdnHeader.meshCount do (
	
	msh = mesh vertices:vertexBuffer[s] faces:faceBuffer[s] material: mat
	fillUVBufferIfEmpty s
	msh.numTVerts = uvBuffer[s].count
	setNumCPVVerts = colourBuffer[s].count
	defaultVCFaces msh
	colorMesh msh
	buildTVFaces msh
	for j = 1 to uvBuffer[s].count do setTVert msh j uvBuffer[s][j]
	for j = 1 to faceBuffer[s].count do setTVFace msh j faceBuffer[s][j]
	for j = 1 to colourBuffer[s].count do setvertColor msh j colourBuffer[s][j]
	
------------------------materialStuff----------------------------------	

	g = 1
	for j = 1 to (vertCountIdx[s].faceSectionCount) do (
		for n = 1 to ((faceCountIdx[(vertCountIdx[s].faceSectionStart + j)].count / 3)) do (
			setFaceMatId msh g ((faceCountIdx[(vertCountIdx[s].faceSectionStart + j)].matGroup) +1)
			g= g + 1
		)		
	)
	
-------------------------boneStuff------------------------------------------	

	if mdnHeader.boneCount != 0 then (
		max modify mode
		skinMod = skin ()
		addModifier msh skinMod
		select msh
		bonepId = vertCountIdx[s].bonePalletId + 1
		
		for j =1 to bonePalletIdx[bonepId].count do (
			maxBone = getnodeByName (bit.intAsHex(boneIdx[(bonePalletIdx[bonepId].boneId[j])].hashName) as string)
			skinOps.addBone skinMod maxBone 0
		)

		modPanel.setCurrentObject skinMod -- this line isn't part of the workaround
		
		for j = 1 to  weightBuffer[s].count do (
			for p = 1 to 4 do (
				if boneBuffer[s][j][p] != 255 then (
					skinOps.SetVertexWeights skinMod j (boneBuffer[s][j][p] +1) weightBuffer[s][j][p]
				)
			)
		)
		
	max create mode
		
	)
	update msh
	
---------------------addtomeshgroup-------------------------------------
	parentLayer = LayerManager.getLayerFromName (bit.intAsHex(meshGroup[(vertCountIdx[s].meshGroupIdx + 1)].hashName) as string)
	parentLayer.addNode msh	
	
)
)
---------------------cleanUpAndFinish------------------------------------

gc()
fclose f