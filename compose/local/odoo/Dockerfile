FROM odoo:16.0

USER root

# COPY ./compose/local/odoo/etc/odoo.conf /etc/odoo/odoo.conf
# Copy template config odoo file
COPY ./compose/local/odoo/etc/odoo.conf /etc/odoo/odoo.conf.template


COPY ./compose/local/odoo/etc/requirements.txt /etc/odoo/requirements.txt

RUN chown odoo:odoo /etc/odoo

# Added to allow debugging on VSCode
RUN pip install -U debugpy
RUN pip install -U ptvsd
RUN pip install -r /etc/odoo/requirements.txt


# reemplace envs odoo.conf
RUN apt-get update && apt-get install -y gettext-base

# reemplace template variables
ENTRYPOINT ["bash", "-c", "envsubst < /etc/odoo/odoo.conf.template > /etc/odoo/odoo.conf && exec odoo"]

USER odoo
