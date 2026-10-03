from PIL import Image, ImageDraw, ImageFont
R='/Users/tusharsharma/Desktop/projects/jaapcounter'
base=Image.open(f'{R}/ios/fastlane/screenshots/hi/01_counter.png').convert('RGB')
W,H=base.size
# 1) Clean background: the Hindi and English heroes share one backdrop, so
# wherever one has lettering the other usually shows the real pixels.
from PIL import ImageFilter, ImageChops
en=Image.open(f'{R}/ios/fastlane/screenshots/en-US/01_counter.png').convert('RGB')
Y0,Y1=1040,1350
def textmask(im):
    g=im.convert('RGB').point(lambda v:v)
    px=im.load(); m=Image.new('L',im.size,0); mp=m.load()
    for y in range(Y0,Y1):
        for x in range(60,1260):
            if sum(px[x,y])<650: mp[x,y]=255
    return m.filter(ImageFilter.MaxFilter(13))
mh=textmask(base); me=textmask(en)
both=ImageChops.multiply(mh,me)
clean=base.copy()
# take English pixels where Hindi has text but English does not
use_en=ImageChops.subtract(mh,me)
clean.paste(en,(0,0),use_en)
# what remains covered in both: interpolate along the row from clean neighbours
px=clean.load(); bp=both.load()
for y in range(Y0,Y1):
    x=60
    while x<1260:
        if bp[x,y]:
            x0=x
            while x<1260 and bp[x,y]: x+=1
            l=px[max(x0-1,0),y]; r=px[min(x,1319),y]
            for xx in range(x0,x):
                t=(xx-x0+1)/(x-x0+1)
                px[xx,y]=tuple(int(l[i]*(1-t)+r[i]*t) for i in range(3))
        else: x+=1
# soften the interpolated seams
sm=clean.filter(ImageFilter.GaussianBlur(3))
clean.paste(sm,(0,0),both.filter(ImageFilter.GaussianBlur(4)))
base=clean
ink=(36,22,14); muted=(110,98,92); dash=(222,190,160)
F='/Users/tusharsharma/Desktop/projects/jaapcounter/'
fonts={'mr':(F+'assets/fonts/NotoSansDevanagari-Bold.ttf',F+'assets/fonts/NotoSansDevanagari-Medium.ttf'),
'gu':(F+'screenshots/fonts/NotoSansGujarati-Bold.ttf',F+'screenshots/fonts/NotoSansGujarati-Regular.ttf'),
'pa':(F+'screenshots/fonts/NotoSansGurmukhi-Bold.ttf',F+'screenshots/fonts/NotoSansGurmukhi-Regular.ttf'),
'ta':(F+'screenshots/fonts/NotoSansTamil-Bold.ttf',F+'screenshots/fonts/NotoSansTamil-Regular.ttf'),
'te':(F+'screenshots/fonts/NotoSansTelugu-Bold.ttf',F+'screenshots/fonts/NotoSansTelugu-Regular.ttf')}
T={'mr':('नाम जप काउंटर','स्मरण','mr-IN'),'gu':('નામ જપ કાઉન્ટર','સ્મરણ','gu-IN'),
'pa':('ਨਾਮ ਜਪ ਕਾਊਂਟਰ','ਸਿਮਰਨ','pa-IN'),'ta':('நாம ஜப கவுண்டர்','ஸ்மரண்','ta-IN'),'te':('నామ జప కౌంటర్','స్మరణ్','te-IN')}
def fit(text,path,maxw,start):
    s=start
    while s>30:
        f=ImageFont.truetype(path,s); b=f.getbbox(text,language=None)
        if b[2]-b[0]<=maxw: return f
        s-=4
    return f
for code,(title,sub,folder) in T.items():
    im=base.copy(); d=ImageDraw.Draw(im)
    bold,reg=fonts[code]
    tf=fit(title,bold,1000,128); sf=fit(sub,reg,420,70)
    tb=tf.getbbox(title); tw=tb[2]-tb[0]
    # title centred, vertically centred on the old title line (~y 1150)
    d.text(((W-tw)/2-tb[0],1150-(tb[1]+tb[3])/2),title,font=tf,fill=ink)
    sb=sf.getbbox(sub); sw=sb[2]-sb[0]
    cy=1268
    d.text(((W-sw)/2-sb[0],cy-(sb[1]+sb[3])/2),sub,font=sf,fill=muted)
    # the two short rules either side of the sub-line
    gap=30
    d.line([(W/2-sw/2-gap-95,cy),(W/2-sw/2-gap,cy)],fill=dash,width=3)
    d.line([(W/2+sw/2+gap,cy),(W/2+sw/2+gap+95,cy)],fill=dash,width=3)
    im.save(f'{R}/ios/fastlane/screenshots/{folder}/01_counter.png')
    im.save(f'/private/tmp/claude-502/-Users-tusharsharma-Desktop-projects-jaapcounter/e8931e23-61cf-4f62-a94c-cf8c830803b2/scratchpad/hero_{code}.png')
# review sheet of the title area
o=Image.new('RGB',(1320,5*330))
for i,c in enumerate(T):
    Image.open(f'/private/tmp/claude-502/-Users-tusharsharma-Desktop-projects-jaapcounter/e8931e23-61cf-4f62-a94c-cf8c830803b2/scratchpad/hero_{c}.png').crop((0,1030,1320,1360)).save('/tmp/_x.png') if False else None
    o.paste(Image.open(f'/private/tmp/claude-502/-Users-tusharsharma-Desktop-projects-jaapcounter/e8931e23-61cf-4f62-a94c-cf8c830803b2/scratchpad/hero_{c}.png').crop((0,1030,1320,1360)),(0,i*330))
o.save('/private/tmp/claude-502/-Users-tusharsharma-Desktop-projects-jaapcounter/e8931e23-61cf-4f62-a94c-cf8c830803b2/scratchpad/hero_sheet.png')
