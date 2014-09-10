module Docsplit

  # Delegates to **pdftk** in order to create bursted single pages from
  # a PDF document.
  class PageExtractor

    # Burst a list of pdfs into single pages, as `pdfname_pagenumber.pdf`.
    def extract(pdfs, opts)
      extract_options opts
      [pdfs].flatten.each do |pdf|
        pdf_name = File.basename(pdf, File.extname(pdf))
        page_path = File.join(@output, "#{pdf_name}_%d.pdf")
        pages = @pages || '1-' + Docsplit.extract_length(pdf).to_s
        FileUtils.mkdir_p @output unless File.exists?(@output)
        
        cmd = if DEPENDENCIES[:pdftailor] # prefer pdftailor, but keep pdftk for backwards compatability
          "pdftailor unstitch --output #{ESCAPE[page_path]} #{ESCAPE[pdf]} 2>&1"
        else
          # Splits doc on page range as `pdfname_pagerange.pdf`.
          "pdftk #{ESCAPE[pdf]} cat #{ESCAPE[pages]} output #{ESCAPE[page_path.gsub('%d', pages)]}"
        end
        result = `#{cmd}`.chomp
        FileUtils.rm('doc_data.txt') if File.exists?('doc_data.txt')
        raise ExtractionFailed, result if $? != 0
        result
      end
    end


    private

    # Extract the relevant GraphicsMagick options from the options hash.
    def extract_options(options)
      @output = options[:output] || '.'
      @pages  = options[:pages]
    end

  end

end