class ReportController < ApplicationController
  def reports

  end

  def report_parameters

  end

  def general_counts
    csv = []
    #[display_name, [test_types], [result_types], [value, [value_modifiers]], min_age, max_age, other, count]
    map = [
        ["HEMATOLOGY",
          [
            ["Full Blood Count", ['FBC'], ['aval'], ['aval', nil], nil, nil, nil, [0, 0, 0]],
            ["Heamoglobin only (blood donors excluded)", ['Hb'], ['Hb'], ['aval', nil], 0, 120, nil, [0, 0, 0]],
            ["Patients with Hb ≤ 6.0g/dl", ['FBC'], ['FBC'], ['available', nil], 0, 120, nil, [0, 0, 0]],
            ["Patients with Hb ≤ 6.0g/dl who were transfused", ['FBC'], ['FBC'], ['aval', nil], 0, 120, nil, [0, 0, 0]],
            ["Patients with Hb > 6.0g/dl", ['FBC'], ['FBC'], ['aval', nil], 0, 120, nil, [0, 0, 0]],
            ["Patients with Hb >6.0g/dl who were transfused", ['FBC'], ['FBC'], ['aval', nil], 0, 120, nil, [0, 0, 0]],
            ["WBC manual count",['FBC'], ['FBC'], ['aval', nil], 0, 120, nil, [0, 0, 0]],
            ["WBC differential", ['FBC'], ['FBC'], ['aval', nil], 0, 120, nil, [0, 0, 0]],
            ["Erythrocyte Sedimentation Rate (ESR)", ['FBC'], ['FBC'], ['aval', nil], 0, 120, nil, [0, 0, 0]],
            ["Sickling Test using sodium metabisulphite", ['FBC'], ['FBC'], ['aval', nil], 0, 120, nil, [0, 0, 0]],
            ["Sickling tests using other methods", ['FBC'], ['FBC'], ['aval', nil], 0, 120, nil, [0, 0, 0]],
            ["Reticulocyte count", ['FBC'], ['FBC'], ['aval', nil], 0, 120, nil, [0, 0, 0]],
            ["Prothrombin time (PT)", ['FBC'], ['FBC'], ['aval', nil], 0, 120, nil, [0, 0, 0]],
            ["Activated Partial Thromboplastin Time (APTT)", ['FBC'], ['FBC'], ['aval', nil], 0, 120, nil, [0, 0, 0]],
            ["International Normalized Ratio (INR)", ['FBC'], ['FBC'], ['aval', nil], 0, 120, nil, [0, 0, 0]],
            ["Bleeding/ cloting time", ['FBC'], ['FBC'], ['aval', nil], 0, 120, nil, [0, 0, 0]],
            ["CD4 absolute count", ['FBC'], ['FBC'], ['aval', nil], 0, 120, nil, [0, 0, 0]],
            ["CD4 percentage", ['FBC'], ['FBC'], ['aval', nil], 0, 120, nil, [0, 0, 0]],
            ["Blood film for red cell morphology", ['FBC'], ['FBC'], ['aval', nil], 0, 120, nil, [0, 0, 0]],
            ["Bleeding/clotting time", ['FBC'], ['FBC'], ['aval', nil], 0, 120, nil, [0, 0, 0]]
          ]
        ],

        ["BLOOD TRANSFUSION SERVICES",
           [
            ["Number of units ordered from MBTS"],
            ["Number of units received from MBTS"],
            ["Number of blood donors registered in the lab"],
            ["Number of blood donors rejected"],
            ["Number of donors rejected due to TTIs"],
            ["Blood donation collected in the laboratory"],
            ["Blood Donor Screening"],
            ["Blood grouping done on prospective donors"],
            ["Heamoglobin Check on donors"],
            ["Blood donors screened for HIV"],
            ["HIV positive donors"],
            ["Blood donors screened for Hepatitis BsAg"],
            ["HepBsAg positive donors"],
            ["Blood donors screened for Syphilis"],
            ["Syphilis positive donors"],
            ["Blood donor Screening for Malaria"],
            ["Transfusion"],
            ["blood grouping done on Patients"],
            ["X- matche for matenity"],
            ["X-macthed for peeds"],
            ["X-matched for others"],
            ["X-matches done in the laboratory"],
            ["X-matches done on patients with Hb ≤ 6.0g/dl"],
            ["X-matches done on patients with Hb > 6.0g/dl"],
            ["X-matches done on patients with unknown Hb"],
            ["Total supected transfision recations"],
            ["Total confirmed transfusion reactions"],
            ["Patients transfused with MBTS blood"],
            ["Those transfused with family replacement blood"],
            ["Number of units returned from the wards"],
            ["Number of units reallocated"],
            ["Blood units lost due to other reasons"],
            ["Expired Blood units"]
          ]
        ],

        ["SEROLOGY",
          [
            ["Syphilis screening on patients"],
            ["Positive tests"],
            ["Syphilis screening on antenatal mothers"],
            ["Positive tests"],
            ["HepBsAg test done on patients"],
            ["Positive tests"],
            ["HepCcAg tests done on patients"],
            ["Positive tests"],
            ["Hcg Pregnacy tests done"],
            ["Positives done"],
            ["HIV tests on PEP patients"],
            ["positives tests"]
          ]
        ],

        ["PARASITOLOGY",
          [
            ["Total malaria microscopy tests done"],
            ["Positive tests"],
            ["Malaria microscopy in ≤ 5yrs"],
            ["Positive malaria slides in <= 5yrs"],
            ["Malaria microscopy in > 5yrs"],
            ["Positive malaria slides in > 5yrs"],
            ["Malaria microscopy in unknown age"],
            ["Positive malaria slides in unknown age"],
            ["Total MRDTs Done"],
            ["MRDTs Positives"],
            ["MRDTs in <= 5yrs"],
            ["MRDT Positives in <= 5yrs"],
            ["MRDTs In >= 5yrs"],
            ["MRDT Positives in >= 5yrs"],
            ["Total invalid MRDTs tests"],
            ["Trypanosome tests"],
            ["Positive tests"],
            ["Urine microscopy total"],
            ["Schistome Haematobium "],
            ["Other urine parasites "],
            ["urine chemistry"],
            ["Semen analysis"],
            ["stool microscopy"],
            ["nemotodes "],
            ["Cematodes"],
            ["trematodes"],
            ["other stool parasites"],
            ["Filarial worm"]
          ]
        ],

        ["CHEMISTRY",
          [
            ["Blood glucose"],
            ["CSF glucose"],
            ["Albumin"],
            ["Alkaline Phosphatase(ALP)"],
            ["Alanine aminotransferase (ALT)"],
            ["Amylase"],
            ["Antistreptolysin O (ASO)"],
            ["Aspartate aminotransferase(AST)"],
            ["Bilirubin Total"],
            ["Bilirubin Direct"],
            ["Calcium"],
            ["Chloride"],
            ["Cholesterol Total"],
            ["Cholesterol LDL"],
            ["Cholesterol HDL"],
            ["Cholinesterase"],
            ["C Reactive Protein (CRP)"],
            ["Creatinine"],
            ["Creatine Kinase NAC"],
            ["Creatine Kinase MB"],
            ["Gamma Glutamyl Transferase"],
            ["Haemoglobin A1c"],
            ["Iron"],
            ["Lipase"],
            ["Lactate Dehydrogenase (LDH)"],
            ["Magnesium"],
            ["Micro-protein"],
            ["Micro-albumin"],
            ["Phosphorus"],
            ["Potassium"],
            ["Rheumatoid Factor"],
            ["Sodium"],
            ["Total Iron Binding Capacity"],
            ["Triglycerides"],
            ["Urea"], ["Uric acid"]
          ]
        ],

        ["MICROBIOLOGY",
          [
            ["Bacterilogy"],
            ["Number of AFB sputum examined"],
            ["Number of new TB cases examined"],
            ["New cases with positive smear"],
            ["Pick-up rate"],
            ["Number of TB follow-up patients"],
            ["Number of uncategorised AFB sputum examined"],
            ["Gene - Xpert Test Results"],
            ["Total cartridges used"],
            ["MTB Not Detected"],
            ["MTB Detected"],
            ["RIF Resistant Detected"],
            ["RIF Resistant Not Detected"],
            ["RIF Resistant Indeterminate"],
            ["Errors /Error Codes"],
            ["Invalid"],
            ["No Results"],
            ["CSF & Other Body Fluids"],
            ["Number of CSF samples analysed"],
            ["Number of CSF samples analysed for AFB"],
            ["Number of CSF samples with organisms"],
            ["HVS analysed"],
            ["Other swabs"],
            ["Number of blood cultures done"],
            ["Positive blood cultures"],
            ["Other body fluids(pleural, Ascitic,synovial etc)"],
            ["Total number of fluids analysed"],
            ["Fluids with organisms"],
            ["Cholera cultures done"],
            ["Positive cholera samples"],
            ["Other stool cultures"],
            ["Stool samples with organisms isolated on culture"],
            ["Number of sensitivity tests done"],
            ["MOLECULAR / HIV"],
            ["DNA-EID samples received "],
            ["DNA-EID samples tests done"],
            ["number with positive results"],
            ["VL tests received"],
            ["VL tests done"],
            ["VL results with less than 1000 copies per ml"]
          ]
        ]
    ]

    case params[:quarter]
      when "Q1"
        start_time = "#{params[:year]}0100000000"
        end_time   = "#{params[:year]}0331235959"
        startA = "#{params[:year]}0100000000"
        startB = "#{params[:year]}0200000000"
        startC = "#{params[:year]}0300000000"
        endA = "#{params[:year]}0131235959"
        endB = "#{params[:year]}0231235959"
        endC = "#{params[:year]}0331235959"
      when "Q2"
        start_time   = "#{params[:year]}0400000000"
        end_time   = "#{params[:year]}0631235959"
        startA = "#{params[:year]}0400000000"
        startB = "#{params[:year]}0500000000"
        startC = "#{params[:year]}0600000000"
        endA = "#{params[:year]}0431235959"
        endB = "#{params[:year]}0531235959"
        endC = "#{params[:year]}0631235959"
      when "Q3"
        start_time = "#{params[:year]}0700000000"
        end_time   = "#{params[:year]}0931235959"
        startA = "#{params[:year]}0700000000"
        startB = "#{params[:year]}0800000000"
        startC = "#{params[:year]}0900000000"
        endA = "#{params[:year]}0731235959"
        endB = "#{params[:year]}0831235959"
        endC = "#{params[:year]}0931235959"
      when "Q4"
        start_time = "#{params[:year]}1000000000"
        end_time   = "#{params[:year]}1231235959"
        startA = "#{params[:year]}1000000000"
        startB = "#{params[:year]}1100000000"
        startC = "#{params[:year]}1200000000"
        endA = "#{params[:year]}1031235959"
        endB = "#{params[:year]}1131235959"
        endC = "#{params[:year]}1231235959"
      else
        raise "Missing Quarter for Year #{params[:year]}".to_s
    end

    o = Order.find("XKCH168B310")
    data = Order.generic.startkey([start_time]).endkey([end_time])
    #[display_name, [test_types], [result_types], [value, value_modifiers], [min_age, modifier], [max_age, modifier], other, count]
    data.each do |order|

      a = 0
      results = order.results || {}
      result_names = results.keys.collect{|r| r.strip}
      date_of_birth = order['patient']['date_of_birth']
      if(order['date_time'].to_i.between?(startA.to_i, endA.to_i))
        result_index = 0
      end

      if(order['date_time'].to_i.between?(startB.to_i, endB.to_i))
        result_index = 1
      end

      if(order['date_time'].to_i.between?(startC.to_i, endC.to_i))
        result_index = 2
      end

      map.each do |dpt, param|
        param.each_with_index do |options, b|

          next if options[0].blank? || options[1].blank?

          test_type = result_names & options[1]
          
          next if (test_type.blank? && options[1][0] != "aval")

          measures = results[test_type]["results"]

          r_names = measures.keys & options[2]
					age = 0
 					if options[4].present? || options[5].present?
						age = -1
            next if date_of_birth.blank?
            (date_of_birth = date_of_birth.to_date) rescue (next) # bad date format e.g 0000-00-00
						age = ((order['date_time'].to_date - date_of_birth)/31557600).round
          end
					
					next if r_names.blank? && options[2][0] != "aval"
					
					if options[2][0] == "aval" ||
						!options[3][0].blank?
						
          	map[a][1][b][7][result_index] += 1; next
					end        

          map[a][1][b][7][result_index] += 1

        end
        a = a + 1
      end
    end

    raise map.inspect

  end

end
