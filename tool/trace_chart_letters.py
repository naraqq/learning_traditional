"""Extract vector ink outlines from the supplied chart and pair with tracing guides.

Dev-only dependencies: numpy, opencv-python-headless. Run from the repo root.
The source image is untouched. Coordinates below are manually annotated pen
centerlines in source-image pixels. These define practice segments, NOT verified
calligraphic stroke order. Components are selected by proximity to those guides,
excluding dotted joining hints, labels, and the chart's ruled lines.
"""
from pathlib import Path
import json
import cv2
import numpy as np

SOURCE = Path('tool/reference/mongolian_alphabet.jpg')
image = cv2.imread(str(SOURCE), cv2.IMREAD_GRAYSCALE)
entries = []

def add(letter, form, box, lines, *, variant=False, group=None):
    entries.append(dict(letter=letter, form=form, box=box, lines=lines,
                        variant=variant, group=group))

# Coordinates are in the original 960 x 1321 photograph; each list is one
# continuous tracing segment. Short separate segments preserve the ink dots.
add('a','initial',(258,82,284,120), [[(274,87),(278,89),(272,94),(267,96),(272,99),(271,103),(265,106),(271,106),(271,115)]])
add('a','medial',(371,95,390,119), [[(383,100),(382,104),(377,107),(383,107),(383,113)]],group='tooth')
add('a','final',(456,100,487,130), [[(478,107),(483,109),(477,115),(469,124),(463,125),(461,122)]],group='swept_tail')
add('a','final',(502,84,530,116), [[(510,90),(509,103),(513,111),(520,111),(524,105)]],variant=True,group='round_tail')
add('e','initial',(258,136,284,167), [[(275,143),(278,146),(270,151),(265,154),(272,153),(271,163)]])
add('e','medial',(373,143,394,169), [[(385,149),(384,154),(380,157),(386,157),(386,163)]],group='tooth')
add('e','final',(456,147,489,180), [[(478,155),(483,158),(476,165),(468,172),(462,173),(461,170)]],group='swept_tail')
add('e','final',(502,134,531,166), [[(510,139),(509,152),(513,158),(520,159),(524,153)]],variant=True,group='round_tail')
add('i','initial',(249,177,284,216), [[(273,184),(277,187),(270,192),(266,195),(272,199),(270,202),(257,210)]])
add('i','medial',(367,189,393,214), [[(385,196),(374,207),(385,199),(385,208)]])
add('i','final',(490,180,525,214), [[(499,187),(498,194),(495,200),(503,190),(514,191),(520,198),(518,206),(513,209)]])
add('ou','initial',(253,222,284,268), [[(274,229),(278,232),(269,237),(264,239),(273,240),(272,246),(262,246),(262,254),(268,257),(273,250),(272,262)]])
add('ou','medial',(370,239,394,271), [[(386,242),(385,248),(378,247),(375,254),(378,259),(385,256),(385,265)]])
add('ou','final',(487,235,527,264), [[(505,240),(504,250),(496,254),(494,250),(497,244),(509,241),(518,244),(520,251),(517,257)]],group='vowel_loop')
add('oeue','initial',(249,270,284,319), [[(273,278),(277,281),(268,286),(264,288),(272,288),(271,299),(264,302),(261,296),(264,291),(272,291),(270,308),(257,313)]])
add('oeue','medial',(364,282,395,322), [[(385,287),(385,293),(378,290),(375,296),(378,302),(385,300),(385,306),(371,313)]])
add('oeue','final',(487,283,527,316), [[(505,291),(504,301),(496,305),(494,301),(497,295),(509,292),(518,295),(520,302),(517,308)]],group='vowel_loop')
add('b','initial',(252,331,288,367), [[(270,337),(270,348),(263,352),(260,347),(263,341),(270,337),(279,341),(282,348),(278,354),(265,360)]])
add('b','medial',(364,329,397,364), [[(378,334),(378,346),(373,351),(369,347),(372,340),(379,337),(386,339),(391,347),(388,352),(372,359)]])
add('b','final',(479,327,524,371), [[(504,332),(505,343),(500,348),(496,344),(498,337),(506,335),(513,338),(517,346),(511,353),(488,365),(485,360)]])
add('s','initial',(255,380,288,419), [[(265,387),(266,393),(281,398),(264,404),(271,406),(271,413)]])
add('s','medial',(364,378,397,418), [[(379,385),(376,392),(371,396),(389,395),(372,405),(381,408)]])
add('s','final',(488,377,522,416), [[(503,384),(500,391),(496,395),(514,394),(497,404),(508,407)]])
add('td','initial',(255,421,285,464), [[(271,448),(264,448),(268,443),(276,437),(276,430),(270,428),(264,431),(266,438),(272,445),(272,456)]])
add('td','medial',(342,423,386,460), [[(377,432),(378,438),(378,451),(378,438),(376,432),(357,442),(350,449),(352,454),(360,454),(365,447),(363,440)]])
add('td','final',(479,425,521,463), [[(513,433),(515,439),(515,452),(515,439),(513,433),(494,443),(488,450),(490,455),(497,455),(502,449),(500,441)]])
add('f','initial',(248,473,288,509), [[(270,480),(269,491),(264,496),(261,491),(255,489),(254,495),(259,496),(254,495),(255,489),(261,491),(264,483),(271,480),(279,483),(282,490),(278,498),(266,503)]])
add('f','medial',(357,472,398,509), [[(378,479),(378,490),(374,495),(369,490),(364,487),(364,494),(367,493),(364,494),(364,487),(369,489),(372,482),(379,479),(387,483),(389,491),(385,498),(374,503)]])
add('f','final',(477,470,523,514), [[(503,477),(503,488),(498,493),(494,488),(490,485),(490,491),(493,491),(490,491),(490,485),(495,487),(498,480),(505,477),(513,481),(516,489),(511,497),(488,508),(483,504)]])
add('g','initial',(246,516,291,553), [[(259,523),(261,530),(259,537),(268,526),(278,526),(283,532),(281,540),(272,544),(264,545)],[(253,536),(253,538)],[(253,544),(253,546)]])
add('g','medial',(344,516,375,552), [[(365,523),(365,528),(359,533),(365,532),(365,537),(359,541),(365,541),(365,547)],[(350,529),(350,531)],[(350,538),(350,540)]])
add('g','medial',(385,513,420,553), [[(394,520),(395,528),(393,533),(401,523),(411,523),(416,530),(413,538),(394,541),(394,548)]],variant=True,group='feminine_bow')
add('g','final',(482,513,522,557), [[(511,520),(513,527),(500,536),(512,533),(511,540),(499,547),(492,551),(489,545)]])
add('kh','initial',(252,565,291,603), [[(262,572),(265,579),(262,585),(272,576),(281,577),(284,582),(281,590),(266,594)]])
add('kh','medial',(350,565,375,601), [[(365,572),(365,578),(359,582),(366,582),(366,587),(360,591),(366,591),(366,596)]])
add('kh','medial',(386,566,421,605), [[(395,573),(396,580),(393,586),(402,575),(411,576),(416,582),(412,590),(394,593),(394,599)]],variant=True,group='feminine_bow')
add('kh','final',(493,566,520,599), [[(506,573),(508,578),(502,582),(508,582),(508,586),(502,590),(513,590)]])
add('jz','initial',(248,617,286,645), [[(277,623),(277,627),(255,636)]],group='slanted_stem')
add('jz','medial',(365,610,394,651), [[(373,618),(373,627),(377,633),(385,633),(385,645)]],group='cup_stem')
add('jz','final',(487,610,516,651), [[(495,618),(495,627),(499,633),(507,633),(507,645)]],group='cup_stem')
add('k','initial',(253,657,288,694), [[(261,676),(262,669),(269,666),(268,677),(267,668),(276,668),(281,674),(278,681),(265,687)]])
add('k','medial',(360,650,395,695), [[(378,660),(378,673),(369,674),(371,667),(379,664),(386,667),(390,674),(386,681),(375,687)]])
add('k','final',(477,652,524,699), [[(504,659),(505,672),(495,674),(497,666),(505,663),(513,667),(518,675),(514,682),(488,693),(483,689)]])
add('l','initial',(254,701,294,739), [[(272,708),(275,712),(262,719),(269,719),(279,722),(284,719),(286,710),(284,719),(279,722),(270,718),(268,732)]])
add('l','medial',(364,705,399,736), [[(379,716),(378,729),(372,725),(380,721),(386,723),(391,720),(391,713)]])
add('l','final',(484,696,526,738), [[(502,703),(500,713),(492,725),(492,729),(501,725),(511,730),(517,727),(518,718)]])
add('m','initial',(255,750,292,787), [[(271,756),(274,760),(262,767),(270,765),(278,762),(284,765),(285,772),(284,765),(278,762),(269,765),(269,780)]])
add('m','medial',(365,753,402,785), [[(379,759),(378,777),(372,769),(382,766),(390,768),(393,775)]])
add('m','final',(487,750,524,786), [[(499,757),(496,769),(495,774),(501,771),(506,775),(497,766),(507,761),(513,765),(517,772),(517,778)]])
add('n','initial',(251,800,282,835), [[(269,805),(274,808),(271,812),(264,815),(271,814),(270,829)],[(257,816),(257,818)]])
add('n','medial',(350,805,374,832), [[(366,811),(365,817),(361,819),(367,819),(367,825)],[(355,820),(355,822)]])
add('n','medial',(386,805,404,831), [[(395,811),(394,817),(390,819),(396,819),(396,825)]],variant=True,group='tooth')
add('n','final',(498,794,528,829), [[(505,801),(505,813),(510,821),(516,821),(520,816)]],group='round_tail')
add('p','initial',(247,837,287,874), [[(269,844),(268,855),(262,859),(258,853),(253,851),(253,846),(260,849),(253,846),(253,851),(256,855),(263,847),(270,845),(277,848),(281,856),(276,863),(265,868)]])
add('p','medial',(357,834,397,873), [[(379,841),(378,852),(372,858),(368,853),(364,849),(364,843),(369,847),(364,843),(364,849),(367,853),(371,846),(380,843),(387,847),(390,855),(385,861),(372,867)]])
add('p','final',(478,831,524,878), [[(505,839),(504,850),(499,856),(494,851),(491,847),(491,841),(495,845),(491,841),(491,847),(494,851),(498,844),(505,841),(513,845),(517,853),(511,861),(488,873),(484,869)]])
add('chts','initial',(250,893,279,936), [[(260,901),(257,921),(271,916),(272,929)]])
add('chts','medial',(364,893,395,936), [[(377,901),(372,921),(386,916),(386,929)]])
add('chts','final',(486,893,518,936), [[(499,901),(495,921),(510,916),(511,929)]])
add('r','initial',(249,941,290,977), [[(280,948),(283,954),(278,958),(281,968),(280,957),(257,969),(281,959),(257,957)]])
add('r','medial',(354,941,396,979), [[(386,948),(388,955),(382,960),(387,970),(386,958),(361,971),(386,961),(365,959)]])
add('r','final',(480,941,526,980), [[(514,948),(515,955),(510,960),(519,964),(516,972),(512,960),(489,970),(513,961),(489,959)]])
add('sh','initial',(255,989,294,1028), [[(266,997),(267,1003),(281,1007),(264,1013),(271,1015),(271,1021)],[(287,1006),(287,1008)],[(287,1013),(287,1015)]])
add('sh','medial',(364,987,402,1028), [[(379,995),(376,1002),(371,1006),(389,1005),(372,1015),(381,1018)],[(396,1004),(396,1006)],[(396,1012),(396,1014)]])
add('sh','final',(487,987,533,1028), [[(504,995),(501,1002),(496,1006),(514,1005),(497,1015),(508,1018)],[(525,1004),(525,1006)],[(525,1014),(525,1016)]])
# The chart explicitly has no initial form for ng.
add('ng','medial',(361,1046,402,1094), [[(374,1054),(371,1059),(377,1062),(375,1067),(373,1073),(384,1066),(393,1069),(395,1077),(391,1083),(383,1086)]])
add('ng','final',(480,1040,520,1094), [[(510,1048),(510,1053),(503,1056),(511,1057),(511,1063),(499,1069),(510,1066),(510,1073),(497,1082),(489,1085),(487,1080)]])
add('v','initial',(249,1100,290,1137), [[(282,1108),(280,1113),(283,1118),(283,1128),(283,1118),(281,1113),(261,1122),(257,1126),(264,1128)]])
add('v','medial',(354,1101,396,1137), [[(387,1109),(386,1114),(388,1119),(388,1129),(388,1119),(386,1114),(366,1123),(362,1127),(369,1129)]])
add('v','final',(482,1100,525,1137), [[(515,1108),(514,1113),(517,1118),(517,1128),(517,1118),(514,1113),(494,1122),(490,1126),(497,1128)]])
add('y','initial',(249,1145,290,1179), [[(259,1159),(256,1165),(261,1167),(280,1159),(280,1153),(281,1158),(283,1171)]])
add('y','medial',(353,1145,397,1179), [[(366,1159),(362,1165),(367,1167),(387,1159),(386,1153),(388,1158),(389,1171)]])
add('y','final',(482,1145,526,1179), [[(494,1159),(490,1165),(495,1167),(515,1159),(514,1153),(516,1158),(517,1171)]])

labels = {
 'a':('А','a'), 'e':('Э','e'), 'i':('И','i'), 'ou':('О / У','o, u'),
 'oeue':('Ө / Ү','ö, ü'), 'b':('Б','b'), 's':('С','s'), 'td':('Т / Д','t, d'),
 'f':('Ф','f'), 'g':('Г','gh'), 'kh':('Х','kh (q)'), 'jz':('Ж / З','j/z'),
 'k':('К','k'), 'l':('Л','l'), 'm':('М','m'), 'n':('Н','n'), 'p':('П','p'),
 'chts':('Ч / Ц','ch/ts'), 'r':('Р','r'), 'sh':('Ш','sh'), 'ng':('НГ','ŋ'),
 'v':('В','v'), 'y':('Й','y'),
}

def clean_contour(contour):
    """Remove sub-pixel staircase noise without merging ink components.

    Uniform arclength sampling makes the blur independent of how densely
    OpenCV encoded any particular edge. The small smoothing radius is in
    original photograph pixels, never screen pixels. Loop contours stay
    separate; compact ink dots retain their size as regular ellipses.
    """
    points = contour.reshape(-1, 2).astype(np.float64)
    lo, hi = points.min(axis=0), points.max(axis=0)
    if max(hi - lo) <= 4 and len(points) >= 3:
        center = (lo + hi) / 2
        radii = np.maximum((hi - lo) / 2, 0.65)
        return np.array([center + radii * [np.cos(t), np.sin(t)]
                         for t in np.linspace(0, 2 * np.pi, 12, endpoint=False)])
    closed = np.vstack([points, points[0]])
    distances = np.linalg.norm(np.diff(closed, axis=0), axis=1)
    cumulative = np.r_[0, np.cumsum(distances)]
    perimeter = cumulative[-1]
    samples = max(12, int(np.ceil(perimeter / 0.4)))
    positions = np.linspace(0, perimeter, samples, endpoint=False)
    uniform = np.column_stack([np.interp(positions, cumulative, closed[:, axis])
                               for axis in range(2)])
    sigma = 0.7 / (perimeter / samples)
    offsets = np.arange(-int(np.ceil(3 * sigma)), int(np.ceil(3 * sigma)) + 1)
    weights = np.exp(-0.5 * (offsets / sigma) ** 2)
    weights /= weights.sum()
    smooth = sum(weight * np.roll(uniform, int(offset), axis=0)
                 for weight, offset in zip(weights, offsets))
    return cv2.approxPolyDP(smooth.astype(np.float32), 0.28, True).reshape(-1, 2)

output=[]
for e in entries:
    x0,y0,x1,y1=e['box']
    crop=image[y0:y1,x0:x1]
    ink=(crop < 125).astype(np.uint8)
    count, components, stats, _ = cv2.connectedComponentsWithStats(ink,8)
    guides=np.zeros_like(ink)
    for line in e['lines']:
        pts=np.array([(x-x0,y-y0) for x,y in line],np.int32)
        cv2.polylines(guides,[pts],False,1,3)
    selected=np.zeros_like(ink)
    for index in range(1,count):
        component=components==index
        if stats[index,cv2.CC_STAT_AREA]>=2 and np.any(component & (guides>0)):
            selected[component]=255
    contours,_=cv2.findContours(selected,cv2.RETR_LIST,cv2.CHAIN_APPROX_SIMPLE)
    assert contours, e
    # One common square transform for outline and guides keeps them aligned.
    points=np.concatenate([c.reshape(-1,2)+[x0,y0] for c in contours]+[np.array(line) for line in e['lines']])
    lo=points.min(axis=0); hi=points.max(axis=0)
    center=(lo+hi)/2; extent=max(hi-lo)+8
    def norm(p):return [round(float((p[i]-center[i])/extent*.84+.5),5) for i in range(2)]
    outlines=[[norm(p+[x0,y0]) for p in clean_contour(c)] for c in contours if len(c)>=3]
    # Subdivide long segments to make the guide robust to pointer smoothing.
    strokes=[]
    for line in e['lines']:
        dense=[]
        for a,b in zip(line,line[1:]):
            a=np.array(a);b=np.array(b)
            for t in np.linspace(0,1,max(2,int(np.linalg.norm(b-a)*2)),endpoint=False):dense.append(norm(a+(b-a)*t))
        dense.append(norm(np.array(line[-1])))
        strokes.append(dense)
    ident=f"{e['letter']}_{e['form']}"+('_alternate' if e['variant'] else '')
    output.append(dict(id=ident,cyrillic=labels[e['letter']][0],transliteration=labels[e['letter']][1],
        form=e['form'],alternate=e['variant'],recognitionGroup=e['group'] or ident,
        outlines=outlines,strokes=strokes,sourceBox=e['box']))

Path('tool/reference/chart_traces.json').write_text(json.dumps(output,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
# Emit ordinary Dart constants: no runtime I/O or package dependencies.
def pts(values):return ', '.join(f'Offset({x}, {y})' for x,y in values)
lines=["// Generated by tool/trace_chart_letters.py from the supplied chart.\n// Do not hand-edit. Source: © Shigüsütei Bagatur; see tool/reference/README.md.\nimport 'dart:ui';\nimport '../models/character_definition.dart';\nimport '../models/reference_stroke.dart';\n\nfinal chartLetters = <CharacterDefinition>["]
for c in output:
    lines += ['  CharacterDefinition(',f"    id: '{c['id']}',",f"    displayName: '{c['transliteration']} — {c['form']}',",f"    cyrillic: '{c['cyrillic']}',",f"    transliteration: '{c['transliteration']}',",f"    form: CharacterForm.{'final_' if c['form']=='final' else c['form']},",f"    alternate: {str(c['alternate']).lower()},",f"    recognitionGroup: '{c['recognitionGroup']}',",'    startZoneRadius: 0.08, endZoneRadius: 0.08, pathTolerance: 0.055,', '    recommendedBrushWidth: 0.035, isDemoData: true,',"    expertReviewNote: 'Outline traced from the supplied Shigüsütei Bagatur chart. Practice segment order is inferred, not specified by the chart.',",'    outlineContours: [']
    lines += [f'      [{pts(contour)}],' for contour in c['outlines']]
    lines += ['    ],','    strokes: [']
    lines += [f'      ReferenceStroke(order: {i+1}, points: [{pts(stroke)}]),' for i,stroke in enumerate(c['strokes'])]
    lines += ['    ],','  ),']
lines += ['];']
Path('lib/src/data/chart_letters.dart').write_text('\n'.join(lines)+'\n',encoding='utf-8')
print(f'Extracted {len(output)} chart forms across {len(labels)} letter groups.')
