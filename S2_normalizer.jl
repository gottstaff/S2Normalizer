using ArchGDAL


cd(ARGS[1]);
filepaths = readdir();
filepaths = filter!(s->occursin(r".tif", s),filepaths);
foreach(filepaths) do f
   output_file =  string("normalized_", f);
    ArchGDAL.read(f) do dataset
       println("\nObject: ", f)
       ref = ArchGDAL.getproj(dataset);
       geotransform = ArchGDAL.getgeotransform(dataset);
       ArchGDAL.create(string("normalized_",f), driver = ArchGDAL.getdriver("GTiff"), width=ArchGDAL.width(dataset), height=ArchGDAL.height(dataset),nbands=ArchGDAL.nraster(dataset), dtype=Float64 )do newdata
          for band_iterator = 1:12
             ArchGDAL.getband(dataset, band_iterator) do rasterband
                normalized_band = convert(Array{Float64},ArchGDAL.read(rasterband))./10000;
                normalized_band[normalized_band.>1] .= 1;
                normalized_band[normalized_band.<=0] .= 0;
                ArchGDAL.write!(newdata, normalized_band,band_iterator);
             end
          end
          ArchGDAL.setgeotransform!(newdata,geotransform);
          ArchGDAL.setproj!(newdata,ref);
       end
    end
end
