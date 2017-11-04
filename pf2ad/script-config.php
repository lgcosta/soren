$samba = false;
foreach ($config['installedpackages']['service'] as $item) {
  if ('samba' == $item['name']) {
    $samba = true;
  }
}
if ($samba == false) {
	$config['installedpackages']['service'][] = array(
	  'name' => 'samba',
	  'rcfile' => 'samba.sh',
	  'executable' => 'smbd',
	  'description' => 'Samba daemon'
  );
}
$samba = false;
foreach ($config['installedpackages']['menu'] as $item) {
  if ('Samba (AD)' == $item['name']) {
    $samba = true;
  }
}
if ($samba == false) {
  $config['installedpackages']['menu'][] = array(
    'name' => 'Samba (AD)',
    'section' => 'Services',
    'url' => '/pkg_edit.php?xml=samba.xml'
  );
}
write_config();
exec;
exit