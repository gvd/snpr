class DasController < ApplicationController

    def show
        @user = User.find_by_id(params[:id])
        if params[:segment]
            @positions = params[:segment].split(":")
            @id = @positions[0] # the chromosome
            @start_and_end = @positions[1].split(",")
            @start = @start_and_end[0]
            @end = @start_and_end[1]
            # Get only those SNPs which have chromosome = id
            # and where position is between start and end
            #
            # Needs some postgresql-magic to force types
            
            @snps = @user.snps.where('CAST(position as integer) <= ? AND CAST(position as integer) >= ? AND CAST(chromosome as text) = ?', @end, @start, @id)
            @user_snps = []
            # ugly solution
            @snps.each do |s|
                # there is only one user_snp for each snp
                @user_snps << UserSnp.find_by_user_id_and_snp_name(@user.id, s.name)
            end
        else
            # no chromosome or start/end, so get nothing
            @user_snps = [] #@user.user_snps
            @id = ""
            @start = ""
            @end  = ""
        end
        render :template => 'das/show.xml.erb', :layout => false
    end
end

