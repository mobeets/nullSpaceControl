function hyps = addPrediction(D, name, latents)

    disp(['Fitting "' name '" hypothesis.']);
    if isfield(D, 'hyps')
        hyps = D.hyps;
        nhyps = numel(hyps);
        ix = strcmp({hyps.name}, name);
        if not(any(ix))
            hyps(nhyps+1).name = name;
            hyps(nhyps+1).latents = latents;
            hyps(nhyps+1).timestamp = datestr(datetime);
        else
            hyps(ix).latents = latents;
            hyps(ix).timestamp = datestr(datetime);
        end
    else
        hyps(1).name = name;
        hyps(1).latents = latents;
        hyps(1).timestamp = datestr(datetime);
    end

end
