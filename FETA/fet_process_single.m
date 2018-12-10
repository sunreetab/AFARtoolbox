function fet_process_single(fn,strFr,ms3D,trackingDir,fit_dir,outDir,normFunc,res,IOD,lmSS,descFunc,patchSize,saveNormVideo,saveNormLandmarks,saveVideoLandmarks)

    descExt = [];
    [~,fnName,~] = fileparts(fn);    
    video_path = fullfile(trackingDir,fn);
    if isfile(video_path)
        fit_file = [fnName '_fit.mat'];
        fit_path = fullfile(fit_dir,fit_file);
        if isfile(fit_path)
            fprintf('- loading tracking: ');
            fitOld = load(fit_path);
            fprintf('done!\n');
            fitOld = fitOld.fit;
            fitOldRange = cell2mat({fitOld(:).frame}');

            fprintf('- opening video: ');
            vo = VideoReader(fn);
            fprintf('done!\n');

            fprintf('- reading last frame: ');
            fprintf('skipped (%d frames)\n',vo.NumberOfFrames);
            if isempty(strFr)
                strFr = 'all frames';
                fr = 1:vo.NumberOfFrames;
            else
                fr = eval(strFr);
                strFr = ['frames ' strFr];        
            end                        

            if saveNormVideo
                out_video_fn = sprintf('(%.4d)_%s_norm.mp4',i,fnName);
                out_video_path = fullfile(outDir,out_video_fn);
                vwNorm = VideoWriter(out_video_path,'MPEG-4');
                vwNorm.FrameRate = vo.FrameRate;
                open(vwNorm);
            end

            if saveVideoLandmarks
                out_annotated_fn = sprintf('(%.4d)_%s_norm_annotated.mp4',i,fnName); 
                out_annotated_path = fullfile(outDir,out_annotated_path); 
                vwNormLand = VideoWriter(out_annotated_path,'MPEG-4');
                vwNormLand.FrameRate = vo.FrameRate;
                open(vwNormLand);
            end

            fprintf('processing %s: ',strFr);
            nFrames = length(fr);
            pts = [];
            pars.normFunc = normFunc;
            pars.normIOD = IOD;
            pars.normRes = res;
            pars.landmarks = lmSS;
            pars.descFunc = descFunc;
            pars.descPatchSize = patchSize;
            feat = struct([]);
            feat(1).pars = pars;
            fitNorm = struct([]);
            fitNorm(1).pars = pars;
            for j = 1:nFrames
                l = true;
                try
                    I = read(vo,fr(j));
                catch
                    l = false;
                end

                pts = [];
                ndx = find(fitOldRange == fr(j));
                if (~isempty(ndx)) && (~isempty(fitOld(ndx).pts_2d)) && (l)
                    pts = fitOld(ndx).pts_2d;
                end

                if ~isempty(pts)
                    [ I_AS, pts_AS ] = normFunc(I, pts, ms3D, res, IOD, lmSS);
                    [ phi, descExt ] = descFunc(I_AS, pts_AS, patchSize, descExt);
                    % eval(['[ I_AS, pts_AS ] = fet_norm_' normFunc '( I, pts, ms3D, res, IOD, lmSS );']);
                    % eval(['[ phi, descExt ] = fet_desc_' descFunc '( I_AS, pts_AS, patchSize, descExt );']);
                    if ~isempty(phi)
                        eval(['phi = phi(' lmSS ',:);']);
                        phi = phi';
                        phi = phi(:)';
                    end                    
                else
                    pts_AS = [];
                    I_AS = zeros(res,res,3,'uint8');
                    phi = [];
                end

                if (~isempty(ndx)) && (l)
                    fitNorm(j).frame = fitOld(ndx).frame;
                    fitNorm(j).isTracked = fitOld(ndx).isTracked;
                    fitNorm(j).pts_2d = pts_AS;
                    feat(j).frame = fitOld(ndx).frame;
                    feat(j).isTracked = fitOld(ndx).isTracked;
                    feat(j).feature = phi;
                    if saveNormVideo
                        writeVideo(vwNorm,I_AS);
                    end

                    if saveVideoLandmarks
                        I_AS = plotShapeRGB(I_AS,pts_AS,[0,255,0]); 
                        writeVideo(vwNormLand,I_AS);
                    end
                end
            end
            fprintf('done!\n');
            fprintf('saving tracking result: ');
            if saveNormVideo
                close(vwNorm);
            end    
            if saveVideoLandmarks
                close(vwNormLand);
            end      
            if saveNormLandmarks
                out_fit_norm_fn = sprintf('(%.4d)_%s_fitNorm.mat',i,fnName);
                out_fit_norm_path = fullfile(outDir,out_fit_norm_fn);
                save(out_fit_norm_path,'fitNorm');
            end

            out_feat_fn = sprintf('(%.4d)_%s_feat.mat',i,fnName);
            out_feat_path = fullfile(outDir,out_feat_fn);
            save(out_feat_path,'feat');
            fprintf('done!\n\n');    
        else
            fprintf('skipped! can''t find tracking file\n\n');    
        end
    else
        fprintf('skipped! can''t find video file\n\n');    
    end
end
