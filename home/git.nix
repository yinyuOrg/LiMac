{
  pkgs,
  lib,
  ...
}:
{
  programs = {
    git =
      let
        difft = lib.getExe pkgs.difftastic;
      in
      {
        enable = true;
        lfs.enable = true;
        settings = {
          alias = {
            co = "checkout";
            st = "status";
            ci = "commit";
            cim = "commit -m";
            civ = "commit -v";
            br = "branch";
            dft = "difftool";
            dlog = "!f() { GIT_EXTERNAL_DIFF=${difft} git log -p --ext-diff $@; }; f";
          };

          diff.tool = "difftastic";
          difftool = {
            prompt = false;
            difftastic = {
              cmd = ''
                ${difft} "$LOCAL" "$REMOTE"
              '';
            };
          };

          pager.difftool = true;

          push.autoSetupRemote = true;
        };
      };
  };
}
