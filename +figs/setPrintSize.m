function setPrintSize(fig, opts)
    if nargin < 2
        opts = struct();
    end
    defopts = struct('width', 5, 'height', 5, 'margin', 0.125);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    set(fig, 'PaperUnits', 'inches');
    set(fig, 'Position', [0 0 opts.width*100 opts.height*100]);
    set(fig, 'PaperSize', [opts.width+2*opts.margin opts.height+2*opts.margin]);
    set(fig, 'PaperPosition', [opts.margin opts.margin opts.width opts.height]);
end
