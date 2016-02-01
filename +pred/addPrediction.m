function hyps = addPrediction(D, name, latents)

    if isfield(D, 'hyps')
        hyps = D.hyps;
        nhyps = numel(hyps);
        ix = strcmp({hyps.name}, name);
        if not(any(ix))
            hyps(nhyps+1).name = name;
            hyps(nhyps+1).latents = latents;
        else
            hyps(ix).latents = latents;
        end
    else
        hyps(1).name = name;
        hyps(1).latents = latents;
    end

end
