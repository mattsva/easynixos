# modules/packages/creative.nix
# ------------------------------------------------------------------------------------------------------------------------
# Media production, design, and creative applications.
# ------------------------------------------------------------------------------------------------------------------------
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [

    # 3D / Video ---------------------------------------------------------------------------------------------------------
    blender                    # 3D modelling, animation, rendering
    kdePackages.kdenlive       # non-linear video editor

    # Audio --------------------------------------------------------------------------------------------------------------
    audacity                   # audio editor
    musescore                  # sheet music notation
    # ardour                   # full DAW (uncomment if needed)
    # lmms                     # LMMS DAW (lightweight)

    # Image editing ------------------------------------------------------------------------------------------------------
    gimp                       # raster image editor
    inkscape                   # vector graphics editor
    krita                      # digital painting

    # Screen recording ---------------------------------------------------------------------------------------------------
    obs-studio                 # screen recording and streaming
    # wf-recorder removed temporarily due to ffmpeg API incompatibility
    # If you want wf-recorder back, either pin ffmpeg to an older API or
    # re-enable wf-recorder after a patched/forked wf-recorder is available.

    # Media players ------------------------------------------------------------------------------------------------------
    mpv                        # fast, scriptable media player
    vlc                        # friendly GUI media player

    # Media conversion / tagging -----------------------------------------------------------------------------------------
    ffmpeg                     # universal media converter (CLI)
    mediainfo                  # media file inspector
    beets                      # music library manager
    zrythm

    opentabletdriver

    kicad
  ];
}
