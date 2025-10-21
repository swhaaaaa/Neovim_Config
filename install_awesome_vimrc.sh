if [ -e ~/.config/nvim ]; then
	echo "rm -rf ~/.config/nvim"
	rm -rf ~/.config/nvim
	echo "rm -rf ~/.local/share/nvim/*"
	rm -rf ~/.local/share/nvim/*
	echo "rm -rf ./nvim/lazy-lock.json"
	rm -rf ./nvim/lazy-lock.json
fi
ln -s $PWD/nvim/ ~/.config/nvim

echo "Installed my Noevim configuration successfully!" 
