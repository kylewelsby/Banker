require 'spec_helper'

describe Banker::Stratagies::LloydsTSB do
  let(:basic_access_start) { File.read(File.expand_path('../../../support/lloyds_tsb/BasicAccessStart.do.html',__FILE__)) }
  let(:basic_access_step1) { File.read(File.expand_path('../../../support/lloyds_tsb/BasicAccessStep1.do.html',__FILE__)) }
  let(:basic_access_step2) { File.read(File.expand_path('../../../support/lloyds_tsb/BasicAccessStep2.do.html',__FILE__)) }
  let(:redirect) { File.read(File.expand_path('../../../support/lloyds_tsb/Redirect.do.html',__FILE__)) }
  let(:export_data1) { File.read(File.expand_path('../../../support/lloyds_tsb/ExportData1.do.html',__FILE__)) }
  let(:data) { File.read(File.expand_path('../../../support/lloyds_tsb/data.ofx',__FILE__)) }

end
