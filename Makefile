
gen:
	./gen_contexts.sh

build: gen
	./gen_images.sh xoelabs/dockery-odoo-base

push:
	docker push xoelabs/dockery-odoo-base:10.0
	docker push xoelabs/dockery-odoo-base:11.0
	docker push xoelabs/dockery-odoo-base:12.0
	docker push xoelabs/dockery-odoo-base:13.0
	docker push xoelabs/dockery-odoo-base:master