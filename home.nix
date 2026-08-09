# ==============================================================================
# Requirements & Dependencies
# ==============================================================================
# Engine:     Home Manager
# Target OS:  Linux

{ config, pkgs, user, nixgl, ... }:

let
  dotfiles = "${config.home.homeDirectory}/.dotfiles";

  wallpaper = pkgs.fetchurl {
    url = "https://unsplash.com/photos/g30P1zcOzXo/download?force=true";
    hash = "sha256-ju465dAE4AemXXwuggyv6OstR6OfaT4zQS91Q/x2f6E=";
  };

  # Instantiate nixGL using your flake's pkgs directly
  nixGLPkgs = import "${nixgl}/default.nix" { inherit pkgs; };
  nixGLPkg = nixGLPkgs.auto.nixGLDefault;

  # Clean shell wrapper that calls the exact Nix store binary
  alacritty-wrapped = pkgs.writeShellScriptBin "alacritty" ''
    exec ${nixGLPkg}/bin/nixGL ${pkgs.alacritty}/bin/alacritty "$@"
  '';
in
{
  # ==============================================================================
  # User & Environment Setup
  # ==============================================================================

  home.username = user;
  home.homeDirectory = "/home/${user}";
  home.stateVersion = "24.11";

  # Linux non-NixOS target integration
  targets.genericLinux.enable = true;
  nixpkgs.config.allowUnfree = true;

  # ==============================================================================
  # Declarative Package Collection
  # ==============================================================================

  home.packages = with pkgs; [
    # Core Shell & Terminal
    alacritty-wrapped
    fzf
    oh-my-zsh
    tmux
    zsh
    zsh-autosuggestions
    zsh-syntax-highlighting

    # System & Search Utilities
    fd
    jq
    net-tools
    proximity-sort
    ripgrep
    tree-sitter

    # Development & Version Control
    gcc
    git
    lazygit
    neovim
    xclip        # X11 clipboard provider

    # Language Servers, Linters & Formatters (Neovim LSP Stack)
    bash-language-server
    clang-tools           # Provides clangd and clang-tidy
    pyright
    ruff
    rust-analyzer
    shellcheck
    shfmt

    # Fonts and Wallpaper
    feh
    nerd-fonts.iosevka-term
    picom

    # Applications
    google-chrome
  ];

  # Enable Fontconfig for user-installed fonts
  fonts.fontconfig.enable = true;

  # ==============================================================================
  # Session Environment Variables
  # ==============================================================================

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # ==============================================================================
  # Out-of-Store Dotfile Symlinks
  # ==============================================================================

  home.file = {
    "repo/.keep".text = "";
    ".wallpaper.jpg".source = wallpaper;
    ".gitconfig".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.gitconfig";
    ".tmux.conf".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.tmux.conf";
    ".zshrc".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.zshrc";
    ".config/alacritty".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/alacritty";
    ".config/nvim".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/nvim";
    ".config/i3".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/i3";
    ".config/i3status".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/i3status";
    ".config/picom".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/picom";
    ".local/bin/tmux-sessionizer" = {
            source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/home/bin/tmux-sessionizer.sh";
    };
  };
}
