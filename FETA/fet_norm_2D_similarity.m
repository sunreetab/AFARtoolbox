function [ I_AS, pts_AS ] = fet_norm_2D_similarity( I, pts, meanFace, res, IOD, lmSS )

    if size(pts,1) == 49
        ndxEye1 = 20:25;
        ndxEye2 = 26:31;
        meanFace = meanFace(18:66,:);
    else
        ndxEye1 = 37:42;
        ndxEye2 = 43:48;        
        meanFace = meanFace(1:size(pts,1),:);
    end
    
    % minXY = min(meanFace(eval(lmSS),1:2),[],1);
    % maxXY = max(meanFace(eval(lmSS),1:2),[],1);
	minXY = min(meanFace(:,1:2),[],1);
    maxXY = max(meanFace(:,1:2),[],1);
      
    meanFace(:,1) = meanFace(:,1) - (maxXY(1) + minXY(1))/2;
    meanFace(:,2) = meanFace(:,2) - (maxXY(2) + minXY(2))/2;    
 
    Tr = CalcSimT(pts,meanFace(:,1:2));
    [ pts_AS, ~ ] = ApplySimT( pts, I, Tr, res );
    
    iod_AS = dist3D( mean(pts_AS(ndxEye1,:),1), mean(pts_AS(ndxEye2,:),1) );
    s = IOD / iod_AS;
    newMeanFace = pts_AS * s;
    % newMeanFace(:,1) = newMeanFace(:,1) - mean(newMeanFace(eval(lmSS),1),1);
    % newMeanFace(:,2) = newMeanFace(:,2) - mean(newMeanFace(eval(lmSS),2),1);

    newMeanFace(:,1) = newMeanFace(:,1) - mean(newMeanFace(:,1),1);
    newMeanFace(:,2) = newMeanFace(:,2) - mean(newMeanFace(:,2),1);
    newMeanFace = newMeanFace + res/2;
    
    Tr = CalcSimT(pts,newMeanFace);
    [ pts_AS, I_AS ] = ApplySimT( pts, I, Tr, res );
    
end