clear
close all

expanded = false;

if expanded
%     filelistELO = getFilesELO();
    filelist = getFilesOther();
%     filelist = [filelistELO; filelist];
    load ELOrdle_expanded_data.mat songData
else
    filelist = getFilesELO();
    load ELOrdle_data.mat songData
end

lf = length(filelist);

% build title list
titlelist = filelist;
for i = 1:lf
    ititle = filelist(i);
    fliptitle = reverse(ititle);
    [fliptit,~] = strtok(fliptitle,'\');
    tit = reverse(fliptit);
    [tit1,tit2] = strtok(tit,'-');
    if ~isempty(tit2)
        tit = lower(char(tit2));
        tit = tit(3:end-4);
    else
        tit = lower(char(tit));
        tit = tit(3:end-4);
    end
    titlelist(i) = string(tit);
end

songInd = randi(lf,1,1);
songtitle = char(lower(titlelist(songInd)));
[y, Fs] = audioread(filelist(songInd));
songlength = length(y)/Fs; %seconds
if songlength < 15
    error(['Song: ' songtitle ' is too short'])
end 
%find random location in song
if songlength > 30
    maxcut = round((songlength-20) * Fs);
    cutind = randi(maxcut,1,1);
    ycut = y(cutind:end,:);
end

try
    thisData = songData(songtitle);
catch
    thisData = {[]};
end
thisData = thisData{1};

%loop through heardle
playlength = 1;
addlength = 1;
playplayer = true;
while playlength <= 16
    fprintf([num2str(playlength) ' sec: '])
    %build player
    cropind = round(playlength) * Fs;
    ycrop = ycut(1:cropind,:);
    if playplayer
        player = audioplayer(ycrop,Fs);
        play(player)
    end
    playplayer = true;
    guess = lower(input("Song name?\n--","s"));
    stop(player)
    if strcmp(guess, songtitle)
        fprintf( '********************************************\n')
        fprintf(['Correct! You guessed the song in ' num2str(playlength) ' seconds.\n'])
        fprintf( '********************************************\n')
        thisData(:,end+1) = [playlength; cutind];
        break
    elseif strcmp(guess,'skip')
        playlength = playlength + addlength;
        addlength = addlength + 1;
    elseif strcmp(guess,'')
        continue
    elseif contains(guess, titlelist)
        fprintf("Incorrect.\n\n")
        %add time
        playlength = playlength + addlength;
        addlength = addlength + 1;
    else
        fprintf('that is not a valid entry. try again\n')
        matchstring = searchmatch(guess, titlelist);
        if ~isempty(matchstring)
            fprintf(['Perhaps you meant: ' matchstring '\n\n'])
        end
        playplayer = false;
    end
end
if playlength > 16
    fprintf(['Sorry! The correct answer was: ' songtitle '\n'])
    thisData(:,end+1) = [nan;cutind];
end
songData(songtitle) = {thisData};
if expanded
    save ELOrdle_expanded_data.mat songData
else
    save ELOrdle_data.mat songData
end
playerFin = audioplayer(y,Fs);
play(playerFin)


input("hit enter to stop playing");
stop(playerFin)


%%
function matchstring = searchmatch(guess, titlelist)
mindist = inf;
for i = 1:length(titlelist)
    ititle = char(titlelist(i));
    dist = strdist(guess,ititle,1,1);
    if dist < mindist
        matchstring = ititle;
        mindist = dist;
    end
end
end

%%
function [d,A]=strdist(r,b,krk,cas)
%d=strdist(r,b,krk,cas) computes Levenshtein and editor distance 
%between strings r and b with use of Vagner-Fisher algorithm.
%   Levenshtein distance is the minimal quantity of character
%substitutions, deletions and insertions for transformation
%of string r into string b. An editor distance is computed as 
%Levenshtein distance with substitutions weight of 2.
%d=strdist(r) computes numel(r);
%d=strdist(r,b) computes Levenshtein distance between r and b.
%If b is empty string then d=numel(r);
%d=strdist(r,b,krk)computes both Levenshtein and an editor distance
%when krk=2. d=strdist(r,b,krk,cas) computes a distance accordingly 
%with krk and cas. If cas>0 then case is ignored.
%
%Example.
% disp(strdist('matlab'))
%    6
% disp(strdist('matlab','Mathworks'))
%    7
% disp(strdist('matlab','Mathworks',2))
%    7    11
% disp(strdist('matlab','Mathworks',2,1))
%    6     9
switch nargin
   case 1
      d=numel(r);
      return
   case 2
      krk=1;
      bb=b;
      rr=r;
   case 3
       bb=b;
       rr=r;
   case 4
      bb=b;
      rr=r;
      if cas>0
         bb=upper(b);
         rr=upper(r);
      end
end
if krk~=2
   krk=1;
end
d=[];
luma=numel(bb);	lima=numel(rr);
lu1=luma+1;       li1=lima+1;
dl=zeros([lu1,li1]);
dl(1,:)=0:lima;   dl(:,1)=0:luma;
%Distance
for krk1=1:krk
for i=2:lu1
   bbi=bb(i-1);
   for j=2:li1
      kr=krk1;
      if strcmp(rr(j-1),bbi)
         kr=0;
      end
   dl(i,j)=min([dl(i-1,j-1)+kr,dl(i-1,j)+1,dl(i,j-1)+1]);
   end
end
d=[d dl(end,end)];
end
end

%%
function filelist = getFilesELO()
filelist = [
"C:\Users\Alex\Music\Electric Light Orchestra\1971 - The Electric Light Orchestra\06 - Mr. Radio.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1971 - The Electric Light Orchestra\07 - Manhattan Rumble (49th Street Massacre).mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1971 - The Electric Light Orchestra\08 - Queen of the Hours.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1971 - The Electric Light Orchestra\09 - Whisper in the Night.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1971 - The Electric Light Orchestra\01 - 10538 Overture.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1971 - The Electric Light Orchestra\02 - Look at Me Now.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1971 - The Electric Light Orchestra\03 - Nellie Takes Her Bow.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1971 - The Electric Light Orchestra\04 - The Battle of Marston Moor (July 2nd 1644).mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1971 - The Electric Light Orchestra\05 - First Movement (Jumping Biz).mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1973 - ELO 2\04 - From The Sun To The World (Boogie #1).mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1973 - ELO 2\05 - Kuiama.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1973 - ELO 2\01 - In Old England Town (Boogie #2).mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1973 - ELO 2\02 - Mama.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1973 - ELO 2\03 - Roll Over Beethoven.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1973 - ELO 2\08 - Baby I Apologise.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1973 - On The Third Day\09 - In The Hall Of The Mountain King.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1973 - On The Third Day\01 - Ocean Breakup-King Of The Universe.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1973 - On The Third Day\02 - Bluebird Is Dead.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1973 - On The Third Day\03 - Oh No Not Susan.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1973 - On The Third Day\04 - New World Rising-Ocean Breakup Reprise.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1973 - On The Third Day\05 - Showdown.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1973 - On The Third Day\06 - Daybreaker.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1973 - On The Third Day\07 - Ma-Ma-Ma Belle.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1973 - On The Third Day\08 - Dreaming Of 4000.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1973 - On The Third Day\13 - Everyone's Born To Die.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1973 - On The Third Day\14 - Interludes.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1974 - Eldorado\01 - Eldorado Overture.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1974 - Eldorado\02 - Can't Get It Out Of My Head.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1974 - Eldorado\03 - Boy Blue.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1974 - Eldorado\04 - Laredo Tornado.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1974 - Eldorado\05 - Poor Boy (The Greenwood).mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1974 - Eldorado\06 - Mister Kingdom.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1974 - Eldorado\07 - Nobody's Child.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1974 - Eldorado\08 - Illusions In G Major.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1974 - Eldorado\09 - Eldorado.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1974 - Eldorado\10 - Eldorado - Finale.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1974 - Eldorado\12 - Dark City.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1975 - Face the Music\01 - Fire On High.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1975 - Face the Music\02 - Waterfall.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1975 - Face the Music\03 - Evil Woman.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1975 - Face the Music\04 - Nightrider.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1975 - Face the Music\05 - Poker.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1975 - Face the Music\06 - Strange Magic.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1975 - Face the Music\07 - Down Home Town.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1975 - Face the Music\08 - One Summer Dream.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1976 - A New World Record\01 - Tightrope.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1976 - A New World Record\02 - Telephone Line.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1976 - A New World Record\03 - Rockaria!.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1976 - A New World Record\04 - Mission (A World Record).mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1976 - A New World Record\05 - So Fine.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1976 - A New World Record\06 - Livin' Thing.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1976 - A New World Record\07 - Above The Clouds.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1976 - A New World Record\08 - Do Ya.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1976 - A New World Record\09 - Shangri-La.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1976 - A New World Record\11 - Surrender.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1977 - Out Of The Blue\01 - Turn To Stone.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1977 - Out Of The Blue\02 - It's Over.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1977 - Out Of The Blue\03 - Sweet Talkin' Woman.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1977 - Out Of The Blue\04 - Across The Border.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1977 - Out Of The Blue\05 - Night In The City.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1977 - Out Of The Blue\06 - Starlight.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1977 - Out Of The Blue\07 - Jungle.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1977 - Out Of The Blue\08 - Believe Me Now.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1977 - Out Of The Blue\09 - Steppin' Out.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1977 - Out Of The Blue\10 - Standin' In The Rain.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1977 - Out Of The Blue\11 - Big Wheels.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1977 - Out Of The Blue\12 - Summer And Lightning.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1977 - Out Of The Blue\13 - Mr. Blue Sky.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1977 - Out Of The Blue\14 - Sweet Is The Night.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1977 - Out Of The Blue\15 - The Whale.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1977 - Out Of The Blue\16 - Birmingham Blues.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1977 - Out Of The Blue\17 - Wild West Hero.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1977 - Out Of The Blue\19 - The Quick And The Daft.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1977 - Out Of The Blue\20 - Latitude 88 North.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1979 - Discovery\01 - Shine A Little Love.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1979 - Discovery\02 - Confusion.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1979 - Discovery\03 - Need Her Love.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1979 - Discovery\04 - The Diary Of Horace Wimp.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1979 - Discovery\05 - Last Train To London.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1979 - Discovery\06 - Midnight Blue.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1979 - Discovery\07 - On The Run.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1979 - Discovery\08 - Wishing.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1979 - Discovery\09 - Don't Bring Me Down.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1979 - Discovery\12 - Little Town Flirt.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1980 - Xanadu [1990 CBS CSCS 6034] Japan\11 - Drum Dreams.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1980 - Xanadu [1990 CBS CSCS 6034] Japan\05 - Xanadu.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1980 - Xanadu [1990 CBS CSCS 6034] Japan\06 - I'm Alive.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1980 - Xanadu [1990 CBS CSCS 6034] Japan\07 - The Fall.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1980 - Xanadu [1990 CBS CSCS 6034] Japan\08 - Don't Walk Away.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1980 - Xanadu [1990 CBS CSCS 6034] Japan\09 - All Over The World.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1981 - Time\01 - Prologue.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1981 - Time\02 - Twilight.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1981 - Time\03 - Yours Truly, 2095.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1981 - Time\04 - Ticket To The Moon.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1981 - Time\05 - The Way Life's Meant To Be.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1981 - Time\06 - Another Heart Breaks.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1981 - Time\07 - Rain Is Falling.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1981 - Time\08 - From The End Of The World.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1981 - Time\09 - The Lights Go Down.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1981 - Time\10 - Here Is The News.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1981 - Time\11 - 21st Century Man.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1981 - Time\12 - Hold On Tight.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1981 - Time\13 - Epilogue.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1981 - Time\14 - The Bouncer.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1981 - Time\15 - When Time Stood Still.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1981 - Time\16 - Julie Don't Live Here.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1983 - Secret Messages\16 - Mandalay.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1983 - Secret Messages\17 - Hello My Old Friend.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1983 - Secret Messages\18 - Beatles Forever.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1983 - Secret Messages\01 - Secret Messages.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1983 - Secret Messages\02 - Loser Gone Wild.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1983 - Secret Messages\03 - Bluebird.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1983 - Secret Messages\04 - Take Me On And On.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1983 - Secret Messages\05 - Time After Time.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1983 - Secret Messages\06 - Four Little Diamonds.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1983 - Secret Messages\07 - Stranger.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1983 - Secret Messages\08 - Danger Ahead.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1983 - Secret Messages\09 - Letter From Spain.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1983 - Secret Messages\10 - Train Of Gold.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1983 - Secret Messages\11 - Rock And Roll Is King.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1983 - Secret Messages\12 - No Way Out.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1983 - Secret Messages\13 - Endless Lies.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1983 - Secret Messages\14 - After All.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1983 - Secret Messages\15 - Buildings Have Eyes.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1986 - Balance Of Power\11 - Opening.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1986 - Balance Of Power\01 - Heaven Only Knows.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1986 - Balance Of Power\02 - So Serious.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1986 - Balance Of Power\03 - Getting To The Point.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1986 - Balance Of Power\04 - Secret Lives.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1986 - Balance Of Power\05 - Is It Alright.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1986 - Balance Of Power\06 - Sorrow About To Fall.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1986 - Balance Of Power\07 - Without Someone.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1986 - Balance Of Power\08 - Calling America.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1986 - Balance Of Power\09 - Endless Lies.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1986 - Balance Of Power\10 - Send It.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1986 - Balance Of Power\13 - In For The Kill.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1986 - Balance Of Power\16 - Caught In A Trap.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\1986 - Balance Of Power\17 - Destination Unknown.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\2001 - Zoom\16 - One Day.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\2001 - Zoom\18 - Lucky Motel.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\2001 - Zoom\01 - Alright.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\2001 - Zoom\02 - Moment In Paradise.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\2001 - Zoom\03 - State Of Mind.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\2001 - Zoom\04 - Just For Love.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\2001 - Zoom\05 - Stranger On A Quiet Street.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\2001 - Zoom\06 - In My Own Time.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\2001 - Zoom\07 - Easy Money.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\2001 - Zoom\08 - It Really Doesn't Matter.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\2001 - Zoom\09 - Ordinary Dream.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\2001 - Zoom\10 - A Long Time Gone.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\2001 - Zoom\11 - Melting In The Sun.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\2001 - Zoom\12 - All She Wanted.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\2001 - Zoom\13 - Lonesome Lullaby.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\2001 - Zoom\14 - Long Black Road.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\2015 - Alone In The Universe\01 - When I Was A Boy.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\2015 - Alone In The Universe\02 - Love And Rain.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\2015 - Alone In The Universe\03 - Dirty To The Bone.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\2015 - Alone In The Universe\04 - When The Night Comes.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\2015 - Alone In The Universe\05 - The Sun Will Shine On You.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\2015 - Alone In The Universe\06 - Ain't It A Drag.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\2015 - Alone In The Universe\07 - All My Life.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\2015 - Alone In The Universe\08 - I'm Leaving You.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\2015 - Alone In The Universe\09 - One Step At A Time.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\2015 - Alone In The Universe\10 - Alone In The Universe.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\2015 - Alone In The Universe\11 - Fault Line.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\2015 - Alone In The Universe\12 - Blue.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\2015 - Alone In The Universe\13 - On My Mind.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\2019 - From Out of Nowhere\05 - Losing You.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\2019 - From Out of Nowhere\06 - One More Time.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\2019 - From Out of Nowhere\07 - Sci-Fi Woman.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\2019 - From Out of Nowhere\08 - Goin' Out On Me.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\2019 - From Out of Nowhere\09 - Time of Our Life.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\2019 - From Out of Nowhere\10 - Songbird.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\2019 - From Out of Nowhere\01 - From Out of Nowhere.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\2019 - From Out of Nowhere\02 - Help Yourself.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\2019 - From Out of Nowhere\03 - All My Love.mp3"
"C:\Users\Alex\Music\Electric Light Orchestra\2019 - From Out of Nowhere\04 - Down Came the Rain.mp3"
];
end
%%
function filelist = getFilesOther()
filelist = [
"C:\Users\Alex\Music\Billy Joel\Piano Man\01 - Travelin' Prayer.mp3"
"C:\Users\Alex\Music\Billy Joel\Piano Man\02 - Piano Man.mp3"
"C:\Users\Alex\Music\Billy Joel\Piano Man\03 - Ain't No Crime.mp3"
"C:\Users\Alex\Music\Billy Joel\Piano Man\04 - You're My Home.mp3"
"C:\Users\Alex\Music\Billy Joel\Piano Man\05 - The Ballad of Billy the Kid.mp3"
"C:\Users\Alex\Music\Billy Joel\Piano Man\06 - Worse Comes To Worst.mp3"
"C:\Users\Alex\Music\Billy Joel\Piano Man\07 - Stop In Nevada.mp3"
"C:\Users\Alex\Music\Billy Joel\Piano Man\08 - If I Only Had the Words.mp3"
"C:\Users\Alex\Music\Billy Joel\Piano Man\09 - Somewhere Along the Line.mp3"
"C:\Users\Alex\Music\Billy Joel\Piano Man\10 - Captain Jack.mp3"
"C:\Users\Alex\Music\Billy Joel\The Stranger\The Stranger.mp3"
"C:\Users\Alex\Music\Billy Joel\The Stranger\Vienna.mp3"

];
end