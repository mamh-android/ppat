package com.marvell.ppat.resource;

import com.marvell.ppat.resource.Resource;
import com.marvell.ppat.resource.ResourceManager;

public class LTKResource implements Resource{
	
	public final String key;

	public LTKResource(String key){
		this.key = key;
		ResourceManager.addResource(key, this);	
	}
	@Override
	public void cleanup() {
		// TODO Auto-generated method stub
		
	}

}
