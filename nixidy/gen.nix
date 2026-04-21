{ inputs, lib, ... }:
{
  flake.modules.nixidy.common = {
    nixidy.applicationImports = (inputs.import-tree.withLib lib).leafs ./_gen;
  };
}
