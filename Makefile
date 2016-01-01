TAG=$(image)

build:
	docker build -t $(TAG) .

run:
	./start.sh $(TAG)
