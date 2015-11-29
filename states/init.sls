#!py
# -*- coding: utf-8 -*-
# vim: ts=4 sw=4 et

__formula__ = 'repos'


def run():
    config = {}
    datamap = __salt__['formhelper.defaults'](__formula__, __env__)
    _gen_state = __salt__['formhelper.generate_state']
    os_family_grain = __salt__['grains.get']('os_family')

    # SLS includes/ excludes
    config['include'] = datamap.get('sls_include', [])
    config['extend'] = datamap.get('sls_extend', {})

    # Preferences
    if os_family_grain == 'Debian':
        for pref, data in datamap.get('preferences', {}).items():
            attrs = [
                    {'name': '{0}/{1}'.format(datamap.get('conf_dir', '/etc/apt/preferences.d'), pref)},
                    {'mode': 644},
                    {'user': 'root'},
                    {'group': 'root'},
                    {'contents_pillar': 'repos:lookup:preferences:{0}:contents'.format(pref)},
                    {'order': 1000},
            ]

            state_id = 'aptpref_{0}'.format(pref)
            config[state_id] = _gen_state('file', 'managed', attrs)

    # Configuration
    if os_family_grain == 'Debian':
        for cfg, data in datamap.get('configs', {}).items():
            attrs = [
                    {'name': '{0}/{1}'.format(datamap.get('conf_dir', '/etc/apt/apt.conf.d'), cfg)},
                    {'mode': 644},
                    {'user': 'root'},
                    {'group': 'root'},
                    {'contents_pillar': 'repos:lookup:configs:{0}:contents'.format(cfg)},
                    {'order': 1000},
                    ]

            state_id = 'repo_conf_{0}'.format(cfg)
            config[state_id] = _gen_state('file', 'managed', attrs)

    # Repositories
    if os_family_grain == 'Debian':
        for repo, data in datamap.get('repos', {}).items():
            attrs = [
                    {'order': 2000},
                    ]

            repo_name = '{0} {1} {2} {3}'.format(data.get('debtype', 'deb'),
                                             data.get('url'),
                                             data.get('dist', __salt__['grains.get']('oscodename')),
                                             ' '.join(data.get('comps', ['main', 'contrib', 'non-free'])))
            attrs.append({'name': repo_name})

            if not data.get('globalfile', False):
                attrs.append({'file': '{0}/{1}.list'.format(datamap.get('sources_dir', ('/etc/apt/sources.list.d')),
                                                     data.get('name', repo))})

            if 'keyuri' in data.keys() or 'keyurl' in data.keys():
                attrs.append({'key_url': data.get('keyuri', data.get('keyurl'))})
            if 'keyid' in data.keys():
                attrs.append({'keyid': data.get('keyid')})
            if 'keyserver' in data.keys():
                attrs.append({'keyserver': data.get('keyserver')})

            state_id = 'repo_{0}'.format(data.get('name', repo))
            config[state_id] = _gen_state('pkgrepo', data.get('ensure', 'managed'), attrs)
    elif os_family_grain == 'RedHat':
        for repo, data in datamap.get('repos', {}).items():
            attrs = [
                    {'humanname': repo},
                    {'order': 2000},
                    {'baseurl': data.get('url')}
                    ]

            if 'keyuri' in data.keys() or 'keyurl' in data.keys():
                attrs.append({'gpgkey': data.get('keyuri', data.get('keyurl'))})
                attrs.append({'gpgcheck': data.get('verify', 1)})
            #if 'keyid' in data.keys():
            #    attrs.append({'keyid': data.get('keyid')})
            #if 'keyserver' in data.keys():
            #    attrs.append({'keyserver': data.get('keyserver')})

            state_id = 'repo_server_{0}'.format(data.get('name', repo))
            config[state_id] = _gen_state('pkgrepo', data.get('ensure', 'managed'), attrs)


    # Packages
    for pkg, data in datamap.get('pkgs', {}).items():
        pkg_ensure = data.get('ensure', 'installed')

        if 'order' in data.keys():
            state_order = data.get('order')
        elif pkg_ensure == 'installed':
            state_order = 2500
        else:
            state_order = 1500

        attrs = [
                {'pkgs': data.get('pkgs')},
                {'order': state_order},
                ]

        state_id = 'repo_package_{0}_{1}'.format(pkg, pkg_ensure)
        config[state_id] = _gen_state('pkg', pkg_ensure, attrs)

    return config
