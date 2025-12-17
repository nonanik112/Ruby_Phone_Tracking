# src/core/build_demo_model.rb
require "torch"
require "fileutils"

class BuildDemoModel
  def self.run
    model = Torch::JIT.trace(Torch.nn.Sequential(
      Torch.nn.Linear.new(16, 32),
      Torch.nn.ReLU.new,
      Torch.nn.Linear.new(32, 16)
    ), Torch.randn([1, 16]))

    FileUtils.mkdir_p("src/models")
    model.save("src/models/license_net.pt")
    puts "✅ Torch model saved: src/models/license_net.pt"
  end
end

# CLI entry
if __FILE__ == $0
  BuildDemoModel.run
end